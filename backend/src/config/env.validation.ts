import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),

  PORT: Joi.number().default(3000),

  SUPABASE_URL: Joi.string().uri().required(),
  SUPABASE_ANON_KEY: Joi.string().min(10).required(),
  SUPABASE_SERVICE_ROLE_KEY: Joi.string().min(10).required(),

  JWT_SECRET: Joi.string().min(32).required(),

  ALLOWED_ORIGINS: Joi.string().optional(),
});
