import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import * as ws from 'ws';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;
  private adminClient: SupabaseClient;

  private readonly supabaseUrl: string;
  private readonly supabaseAnonKey: string;

  constructor(private config: ConfigService) {
    this.supabaseUrl     = this.config.getOrThrow('SUPABASE_URL');
    this.supabaseAnonKey = this.config.getOrThrow('SUPABASE_ANON_KEY');

    const options = {
      realtime: { transport: ws as any },
    };

    this.client = createClient(this.supabaseUrl, this.supabaseAnonKey, options);

    this.adminClient = createClient(
      this.supabaseUrl,
      this.config.getOrThrow('SUPABASE_SERVICE_ROLE_KEY'),
      options,
    );
  }

  getClient(): SupabaseClient {
    return this.client;
  }

  getAdminClient(): SupabaseClient {
    return this.adminClient;
  }

  // Cria um client que respeita as RLS policies do usuário autenticado.
  // Use para operações de escrita onde o Supabase deve aplicar as policies.
  getUserClient(accessToken: string): SupabaseClient {
    return createClient(this.supabaseUrl, this.supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${accessToken}` } },
    });
  }
}
