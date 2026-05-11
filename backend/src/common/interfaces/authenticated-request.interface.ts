import { Request } from 'express';

export interface AuthUser {
  id: string;
  email: string;
  full_name: string;
  role: 'morador' | 'prestador';
  avatar_url: string | null;
  phone: string | null;
  bio: string | null;
  neighborhood: string | null;
  city: string | null;
  state: string | null;
}

export interface AuthenticatedRequest extends Request {
  user: AuthUser;
}
