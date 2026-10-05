alter account set AI_SETTINGS = $$
  guardrails:
    advanced_prompt_injection:
      - enabled: true
$$;

alter account unset AI_SETTINGS;
