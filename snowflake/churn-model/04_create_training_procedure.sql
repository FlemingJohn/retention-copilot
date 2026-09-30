use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace procedure RETENTION_COPILOT.ANALYTICS.TRAIN_CHURN_MODEL()
returns varchar
language python
runtime_version = '3.11'
packages = ('snowflake-snowpark-python','scikit-learn','numpy')
handler = 'train_churn_model'
as
$$
def train_churn_model(session):
    import numpy as np
    import pickle
    import io
    import datetime
    from sklearn.linear_model import LogisticRegression
    from sklearn.ensemble import HistGradientBoostingClassifier
    from sklearn.metrics import roc_auc_score, average_precision_score
    from sklearn.preprocessing import StandardScaler
    numeric_columns = [
        'TENURE_MONTHS','ACTIVE_POLICIES','TOTAL_MONTHLY_PREMIUM','PRODUCT_COUNT',
        'PAYMENTS_COUNT','LATE_PAYMENTS','FAILED_PAYMENTS','LATE_OR_FAILED_RATE',
        'AVERAGE_DAYS_LATE','CLAIMS_COUNT','OPEN_CLAIMS','REJECTED_CLAIMS',
        'TOTAL_CLAIMED_AMOUNT','AVERAGE_RESOLUTION_DAYS','TICKETS_COUNT',
        'OPEN_TICKETS','ESCALATED_TICKETS','AVERAGE_SATISFACTION','LOWEST_SATISFACTION',
        'CALLS_COUNT','AVERAGE_SENTIMENT','LOWEST_SENTIMENT','NEGATIVE_CALLS',
        'RIVAL_MENTIONS','CANCEL_INTENT_CALLS','DAYS_SINCE_LAST_CALL']
    segment_values = ['Gold','Silver','Standard']
    product_values = ['Motor','Health','Life','Home','Travel']
    log_scale_columns = {'TOTAL_MONTHLY_PREMIUM','TOTAL_CLAIMED_AMOUNT'}
    driver_templates = {
        'LATE_PAYMENTS':('{:.0f} late payment','{:.0f} late payments'),
        'FAILED_PAYMENTS':('{:.0f} failed payment','{:.0f} failed payments'),
        'LATE_OR_FAILED_RATE':'{:.1%} late-or-failed rate',
        'AVERAGE_DAYS_LATE':'average {:.1f} days late',
        'CANCEL_INTENT_CALLS':('{:.0f} cancellation-intent call','{:.0f} cancellation-intent calls'),
        'RIVAL_MENTIONS':('{:.0f} rival mention','{:.0f} rival mentions'),
        'AVERAGE_SENTIMENT':'average call sentiment {:.2f}',
        'LOWEST_SENTIMENT':'lowest call sentiment {:.2f}',
        'NEGATIVE_CALLS':('{:.0f} negative-sentiment call','{:.0f} negative-sentiment calls'),
        'ESCALATED_TICKETS':('{:.0f} escalated ticket','{:.0f} escalated tickets'),
        'OPEN_TICKETS':('{:.0f} open ticket','{:.0f} open tickets'),
        'REJECTED_CLAIMS':('{:.0f} rejected claim','{:.0f} rejected claims'),
        'AVERAGE_SATISFACTION':'average satisfaction {:.1f}',
        'LOWEST_SATISFACTION':'lowest satisfaction {:.0f}',
        'TOTAL_CLAIMED_AMOUNT':'total claimed {:.0f} rupees',
        'TOTAL_MONTHLY_PREMIUM':'monthly premium {:.0f} rupees',
        'TENURE_MONTHS':('tenure {:.0f} month','tenure {:.0f} months'),
        'DAYS_SINCE_LAST_CALL':('{:.0f} day since last call','{:.0f} days since last call'),
        'OPEN_CLAIMS':('{:.0f} open claim','{:.0f} open claims'),
        'CLAIMS_COUNT':('{:.0f} claim filed','{:.0f} claims filed'),
        'TICKETS_COUNT':('{:.0f} service ticket','{:.0f} service tickets'),
        'CALLS_COUNT':('{:.0f} call made','{:.0f} calls made')}
    reportable_features = {
        'LATE_PAYMENTS','FAILED_PAYMENTS','LATE_OR_FAILED_RATE','AVERAGE_DAYS_LATE',
        'CANCEL_INTENT_CALLS','RIVAL_MENTIONS','AVERAGE_SENTIMENT','LOWEST_SENTIMENT',
        'NEGATIVE_CALLS','ESCALATED_TICKETS','OPEN_TICKETS','REJECTED_CLAIMS',
        'AVERAGE_SATISFACTION','LOWEST_SATISFACTION','TICKETS_COUNT','OPEN_CLAIMS','CALLS_COUNT'}
    customer_profile_table = 'RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE'
    churn_labels_table = 'RETENTION_COPILOT.ANALYTICS.CHURN_LABELS'
    churn_split_table = 'RETENTION_COPILOT.ANALYTICS.CHURN_SPLIT'
    model_results_table = 'RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS'
    churn_scores_table = 'RETENTION_COPILOT.ANALYTICS.CHURN_SCORES'
    run_timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    def run_query(sql):
        return session.sql(sql).collect()
    def build_row_vector(row):
        values = []
        for column in numeric_columns:
            raw = row[column]
            if raw is None:
                values.append(np.nan)
            elif column in log_scale_columns:
                values.append(np.log1p(float(raw)))
            else:
                values.append(float(raw))
        for segment in segment_values:
            values.append(1.0 if row['SEGMENT'] == segment else 0.0)
        for product in product_values:
            values.append(1.0 if product in str(row['PRODUCTS_HELD'] or '') else 0.0)
        return values
    def build_matrix(rows, missing_flag_columns=None):
        result = []
        for row in rows:
            vector = build_row_vector(row)
            if missing_flag_columns:
                flags = [1.0 if np.isnan(vector[index]) else 0.0 for index in missing_flag_columns]
                vector = vector + flags
            result.append(vector)
        return np.array(result, dtype=float)
    def extract_labels(rows):
        return np.array([1 if row['CHURNED_WITHIN_90_DAYS'] else 0 for row in rows])
    def top20_capture(true_labels, predicted_probs):
        cutoff = max(1, int(0.2 * len(true_labels)))
        top_indices = np.argsort(predicted_probs)[::-1][:cutoff]
        return float(true_labels[top_indices].sum()) / max(1, true_labels.sum())
    def insert_result(model_name, split_name, metric_name, metric_value):
        run_query(f"insert into {model_results_table} values('{model_name}','{split_name}','{metric_name}',{metric_value},'{run_timestamp}')")
    def format_driver(feature_name, row):
        if feature_name in numeric_columns:
            raw = row[feature_name]
            if raw is None:
                return f"{feature_name.lower().replace('_',' ')} data missing"
            value = float(raw)
            template = driver_templates.get(feature_name)
            if template is None:
                return f"{feature_name.lower().replace('_',' ')} {value:.2g}"
            if isinstance(template, tuple):
                return (template[0] if abs(value - 1.0) < 0.5 else template[1]).format(value)
            return template.format(value)
        if feature_name.startswith('SEG_'):
            return f"customer segment {feature_name[4:]}"
        if feature_name.startswith('PROD_'):
            return f"holds {feature_name[5:]} policy"
        return f"{feature_name[5:].lower().replace('_',' ')} data missing"
    def is_adverse(feature_name, raw_value):
        if raw_value is None:
            return False
        value = float(raw_value)
        if feature_name in ('AVERAGE_SENTIMENT', 'LOWEST_SENTIMENT'):
            return value < 0
        if feature_name in ('AVERAGE_SATISFACTION', 'LOWEST_SATISFACTION'):
            return value <= 3
        return value > 0
    def impute_medians(matrix, column_medians):
        result = matrix.copy()
        for index, median in enumerate(column_medians):
            missing_mask = np.isnan(result[:, index])
            if missing_mask.any():
                result[missing_mask, index] = median
        return result
    column_select = 'cp.CUSTOMER_ID,' + ','.join('cp.' + c for c in numeric_columns) + ',cp.SEGMENT,cp.PRODUCTS_HELD'
    base_query = ('select ' + column_select + ',cl.CHURNED_WITHIN_90_DAYS from '
                  + customer_profile_table + ' cp join ' + churn_labels_table
                  + ' cl on cp.CUSTOMER_ID=cl.CUSTOMER_ID join ' + churn_split_table
                  + ' s on cp.CUSTOMER_ID=s.CUSTOMER_ID where s.SPLIT=')
    train_rows = run_query(base_query + "'train'")
    test_rows = run_query(base_query + "'test'")
    all_rows = run_query('select ' + column_select + ' from ' + customer_profile_table
                         + ' cp join ' + churn_labels_table + ' cl on cp.CUSTOMER_ID=cl.CUSTOMER_ID')
    train_labels = extract_labels(train_rows)
    test_labels = extract_labels(test_rows)
    raw_train_matrix = build_matrix(train_rows)
    raw_test_matrix = build_matrix(test_rows)
    raw_all_matrix = build_matrix(all_rows)
    missing_flag_columns = [i for i in range(len(numeric_columns))
                             if np.mean(np.isnan(raw_train_matrix[:, i])) > 0.1]
    train_matrix = build_matrix(train_rows, missing_flag_columns)
    test_matrix = build_matrix(test_rows, missing_flag_columns)
    all_matrix = build_matrix(all_rows, missing_flag_columns)
    column_medians = [
        float(np.nanmedian(train_matrix[:, i])) if not np.all(np.isnan(train_matrix[:, i])) else 0.0
        for i in range(train_matrix.shape[1])]
    scaler = StandardScaler()
    scaled_train = scaler.fit_transform(impute_medians(train_matrix, column_medians))
    scaled_test = scaler.transform(impute_medians(test_matrix, column_medians))
    scaled_all = scaler.transform(impute_medians(all_matrix, column_medians))
    logistic_model = LogisticRegression(C=1.0, max_iter=1000, random_state=42)
    logistic_model.fit(scaled_train, train_labels)
    boosting_model = HistGradientBoostingClassifier(max_depth=4, learning_rate=0.05, max_iter=300, early_stopping=True, random_state=42)
    boosting_model.fit(raw_train_matrix, train_labels)
    logistic_train_probs = logistic_model.predict_proba(scaled_train)[:, 1]
    logistic_test_probs = logistic_model.predict_proba(scaled_test)[:, 1]
    boosting_train_probs = boosting_model.predict_proba(raw_train_matrix)[:, 1]
    boosting_test_probs = boosting_model.predict_proba(raw_test_matrix)[:, 1]
    random_generator = np.random.default_rng(0)
    shuffled_logistic = LogisticRegression(C=1.0, max_iter=1000, random_state=42)
    shuffled_logistic.fit(scaled_train, random_generator.permutation(train_labels))
    shuffled_auc = roc_auc_score(test_labels, shuffled_logistic.predict_proba(scaled_test)[:, 1])
    run_query(f"truncate table {model_results_table}")
    run_query(f"truncate table {churn_scores_table}")
    insert_result('logistic_regression','train','roc_auc',roc_auc_score(train_labels,logistic_train_probs))
    insert_result('logistic_regression','test','roc_auc',roc_auc_score(test_labels,logistic_test_probs))
    insert_result('logistic_regression','train','average_precision',average_precision_score(train_labels,logistic_train_probs))
    insert_result('logistic_regression','test','average_precision',average_precision_score(test_labels,logistic_test_probs))
    insert_result('logistic_regression','train','top20_capture',top20_capture(train_labels,logistic_train_probs))
    insert_result('logistic_regression','test','top20_capture',top20_capture(test_labels,logistic_test_probs))
    insert_result('gradient_boosting','train','roc_auc',roc_auc_score(train_labels,boosting_train_probs))
    insert_result('gradient_boosting','test','roc_auc',roc_auc_score(test_labels,boosting_test_probs))
    insert_result('gradient_boosting','train','average_precision',average_precision_score(train_labels,boosting_train_probs))
    insert_result('gradient_boosting','test','average_precision',average_precision_score(test_labels,boosting_test_probs))
    insert_result('gradient_boosting','train','top20_capture',top20_capture(train_labels,boosting_train_probs))
    insert_result('gradient_boosting','test','top20_capture',top20_capture(test_labels,boosting_test_probs))
    insert_result('logistic_regression_shuffled','test','roc_auc_shuffled_labels',shuffled_auc)
    logistic_test_auc = roc_auc_score(test_labels, logistic_test_probs)
    boosting_test_auc = roc_auc_score(test_labels, boosting_test_probs)
    chosen_model_name = 'gradient_boosting' if boosting_test_auc - logistic_test_auc >= 0.02 else 'logistic_regression'
    insert_result(chosen_model_name, 'selection', 'chosen_model', 1.0)
    buffer = io.BytesIO()
    pickle.dump({'logistic_model':logistic_model,'boosting_model':boosting_model,'scaler':scaler,'column_medians':column_medians,'missing_flag_columns':missing_flag_columns,'chosen_model_name':chosen_model_name}, buffer)
    buffer.seek(0)
    session.file.put_stream(buffer, '@RETENTION_COPILOT.ANALYTICS.MODEL_STAGE/churn_model.pkl', auto_compress=False, overwrite=True)
    use_boosting = chosen_model_name == 'gradient_boosting'
    active_model = boosting_model if use_boosting else logistic_model
    scoring_matrix = raw_all_matrix if use_boosting else scaled_all
    feature_names = (numeric_columns + ['SEG_'+s for s in segment_values] + ['PROD_'+p for p in product_values]
                     + ([] if use_boosting else ['MISS_'+numeric_columns[i] for i in missing_flag_columns]))
    base_probabilities = active_model.predict_proba(scoring_matrix)[:, 1]
    occlusion_drops = np.zeros((len(all_rows), scoring_matrix.shape[1]))
    for feature_index in range(scoring_matrix.shape[1]):
        occluded_matrix = scoring_matrix.copy()
        occluded_matrix[:, feature_index] = np.nan if (use_boosting and feature_index < len(numeric_columns)) else 0.0
        occlusion_drops[:, feature_index] = base_probabilities - active_model.predict_proba(occluded_matrix)[:, 1]
    high_threshold = np.percentile(base_probabilities, 90)
    medium_threshold = np.percentile(base_probabilities, 70)
    test_customer_ids = {row['CUSTOMER_ID'] for row in test_rows}
    test_customer_mask = np.array([row['CUSTOMER_ID'] in test_customer_ids for row in all_rows])
    for feature_index, feature_name in enumerate(feature_names):
        test_drops = occlusion_drops[test_customer_mask, feature_index]
        if len(test_drops) > 0:
            insert_result(chosen_model_name, 'feature_importance', f'importance_{feature_name}', float(np.mean(np.abs(test_drops))))
    score_batch = []
    for row_index, row in enumerate(all_rows):
        probability = float(base_probabilities[row_index])
        tier = 'High' if probability >= high_threshold else ('Medium' if probability >= medium_threshold else 'Low')
        is_test = 'TRUE' if row['CUSTOMER_ID'] in test_customer_ids else 'FALSE'
        drop_vector = occlusion_drops[row_index]
        ranked_indices = [j for j in np.argsort(drop_vector)[::-1] if drop_vector[j] > 0]
        reportable_indices = [j for j in ranked_indices
                              if feature_names[j] in reportable_features
                              and is_adverse(feature_names[j], row[feature_names[j]])]
        top_feature_indices = [] if tier == 'Low' else reportable_indices[:3]
        drivers = [format_driver(feature_names[j], row) for j in top_feature_indices]
        while len(drivers) < 3:
            drivers.append('')
        driver_1, driver_2, driver_3 = [d.replace("'", "''") for d in drivers]
        score_batch.append(f"('{row['CUSTOMER_ID']}',{probability},'{tier}','{driver_1}','{driver_2}','{driver_3}','{chosen_model_name}',{is_test},'{run_timestamp}')")
        if len(score_batch) >= 500:
            run_query(f"insert into {churn_scores_table} values {','.join(score_batch)}")
            score_batch = []
    if score_batch:
        run_query(f"insert into {churn_scores_table} values {','.join(score_batch)}")
    chosen_test_auc = boosting_test_auc if use_boosting else logistic_test_auc
    return f"Chosen: {chosen_model_name}. Test ROC AUC: {chosen_test_auc:.4f}. Shuffled AUC: {shuffled_auc:.4f}."
$$
;
