import {
  registerDecorator,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';

/**
 * Valida número de WhatsApp brasileiro.
 *
 * Formatos aceitos (somente dígitos, sem máscara):
 *   - Celular com DDD: 11999999999  (11 dígitos, 9 obrigatório)
 *   - Fixo   com DDD: 1133334444   (10 dígitos)
 *
 * DDD válidos: 11–19, 21, 22, 24, 27, 28, 31–35, 37, 38,
 *              41–44, 45–49, 51, 53–55, 61, 62, 63–65, 66–69,
 *              71, 73–77, 79, 81–89, 91–99
 */
const VALID_DDD = new Set([
  11, 12, 13, 14, 15, 16, 17, 18, 19,
  21, 22, 24, 27, 28,
  31, 32, 33, 34, 35, 37, 38,
  41, 42, 43, 44, 45, 46, 47, 48, 49,
  51, 53, 54, 55,
  61, 62, 63, 64, 65, 66, 67, 68, 69,
  71, 73, 74, 75, 77, 79,
  81, 82, 83, 84, 85, 86, 87, 88, 89,
  91, 92, 93, 94, 95, 96, 97, 98, 99,
]);

/** Retorna true se a string é um número de WhatsApp válido */
export function isValidWhatsApp(value: unknown): boolean {
  if (typeof value !== 'string') return false;

  // Remove qualquer caractere não-numérico antes de validar
  const digits = value.replace(/\D/g, '');

  if (digits.length !== 10 && digits.length !== 11) return false;

  const ddd = Number(digits.slice(0, 2));
  if (!VALID_DDD.has(ddd)) return false;

  if (digits.length === 11) {
    // Celular: terceiro dígito obrigatoriamente 9
    return digits[2] === '9';
  }

  // Fixo: terceiro dígito entre 2–5
  return ['2', '3', '4', '5'].includes(digits[2]);
}

@ValidatorConstraint({ name: 'IsWhatsApp', async: false })
export class IsWhatsAppConstraint implements ValidatorConstraintInterface {
  validate(value: unknown): boolean {
    return isValidWhatsApp(value);
  }

  defaultMessage(): string {
    return 'whatsapp deve ser um número brasileiro válido (ex: 11999999999)';
  }
}

/**
 * Valida que o campo é um número de WhatsApp/telefone brasileiro válido.
 * Aceita somente dígitos, 10 ou 11 caracteres, com DDD válido.
 *
 * @example
 * \@IsWhatsApp()
 * whatsapp: string;
 */
export function IsWhatsApp(options?: ValidationOptions): PropertyDecorator {
  return (object, propertyName) => {
    registerDecorator({
      target: object.constructor,
      propertyName: propertyName as string,
      options,
      constraints: [],
      validator: IsWhatsAppConstraint,
    });
  };
}