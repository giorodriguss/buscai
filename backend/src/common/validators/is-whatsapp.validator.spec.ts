import { isValidWhatsApp, IsWhatsAppConstraint } from './is-whatsapp.validator';

describe('isValidWhatsApp', () => {
  describe('celulares válidos (11 dígitos, DDD válido, 9 como terceiro dígito)', () => {
    it.each([
      ['11999999999', 'SP'],
      ['21988887777', 'RJ'],
      ['71981234567', 'BA'],
      ['61987654321', 'DF'],
      ['51996543210', 'RS'],
      ['41999998888', 'PR'],
      ['85991234567', 'CE'],
      ['92999887766', 'AM'],
    ])('aceita %s (%s)', (num) => {
      expect(isValidWhatsApp(num)).toBe(true);
    });
  });

  describe('telefones fixos válidos (10 dígitos, DDD válido, terceiro dígito 2–5)', () => {
    it.each([
      '1133334444',
      '2122334455',
      '3132455678',
      '4133445566',
      '5133445566',
    ])('aceita %s', (num) => {
      expect(isValidWhatsApp(num)).toBe(true);
    });
  });

  describe('aceita formatos com máscara (remove não-dígitos)', () => {
    it('aceita número com hífens', () => {
      expect(isValidWhatsApp('11-9999-99999')).toBe(true);
    });

    it('aceita número com parênteses e hífens', () => {
      expect(isValidWhatsApp('(11) 99999-9999')).toBe(true);
    });

    it('aceita número com espaços', () => {
      expect(isValidWhatsApp('11 99999 9999')).toBe(true);
    });

    it('aceita número com ponto', () => {
      expect(isValidWhatsApp('11.99999.9999')).toBe(true);
    });
  });

  describe('rejeita entradas inválidas', () => {
    it('rejeita DDD inválido (20 não existe)', () => {
      expect(isValidWhatsApp('20999999999')).toBe(false);
    });

    it('rejeita DDD inválido (00 não existe)', () => {
      expect(isValidWhatsApp('00999999999')).toBe(false);
    });

    it('rejeita celular sem o 9 obrigatório como terceiro dígito', () => {
      expect(isValidWhatsApp('11888888888')).toBe(false);
    });

    it('rejeita celular com terceiro dígito 8 (inválido)', () => {
      expect(isValidWhatsApp('11899999999')).toBe(false);
    });

    it('rejeita fixo com terceiro dígito 6 (inválido para fixo)', () => {
      expect(isValidWhatsApp('1163334444')).toBe(false);
    });

    it('rejeita fixo com terceiro dígito 1 (inválido para fixo)', () => {
      expect(isValidWhatsApp('1113334444')).toBe(false);
    });

    it('rejeita número com menos de 10 dígitos', () => {
      expect(isValidWhatsApp('119999999')).toBe(false);
    });

    it('rejeita número com mais de 11 dígitos', () => {
      expect(isValidWhatsApp('119999999999')).toBe(false);
    });

    it('rejeita string vazia', () => {
      expect(isValidWhatsApp('')).toBe(false);
    });

    it('rejeita null', () => {
      expect(isValidWhatsApp(null)).toBe(false);
    });

    it('rejeita undefined', () => {
      expect(isValidWhatsApp(undefined)).toBe(false);
    });

    it('rejeita valor numérico', () => {
      expect(isValidWhatsApp(11999999999)).toBe(false);
    });

    it('rejeita objeto', () => {
      expect(isValidWhatsApp({ number: '11999999999' })).toBe(false);
    });

    it('rejeita string apenas com letras', () => {
      expect(isValidWhatsApp('abcdefghijk')).toBe(false);
    });
  });
});

describe('IsWhatsAppConstraint', () => {
  let constraint: IsWhatsAppConstraint;

  beforeEach(() => {
    constraint = new IsWhatsAppConstraint();
  });

  it('retorna true para número válido', () => {
    expect(constraint.validate('11999999999')).toBe(true);
  });

  it('retorna false para número inválido', () => {
    expect(constraint.validate('invalido')).toBe(false);
  });

  it('delega validação corretamente para isValidWhatsApp', () => {
    expect(constraint.validate('11999999999')).toBe(isValidWhatsApp('11999999999'));
    expect(constraint.validate('00000000000')).toBe(isValidWhatsApp('00000000000'));
  });

  it('retorna mensagem de erro contendo "whatsapp"', () => {
    expect(constraint.defaultMessage().toLowerCase()).toContain('whatsapp');
  });

  it('mensagem de erro menciona formato esperado', () => {
    expect(constraint.defaultMessage()).toContain('11999999999');
  });
});
