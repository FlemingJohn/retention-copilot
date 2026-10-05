alter account set AI_SETTINGS = $$
  guardrails:
    advanced_prompt_injection:
      - enabled: true
$$;

show parameters like 'AI_SETTINGS' in account;
