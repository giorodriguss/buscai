import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import * as ws from 'ws';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;
  private adminClient: SupabaseClient;

  constructor(private config: ConfigService) {
    const options = {
      realtime: { transport: ws as any },
    };

    this.client = createClient(
      this.config.getOrThrow('SUPABASE_URL'),
      this.config.getOrThrow('SUPABASE_ANON_KEY'),
      options,
    );

    this.adminClient = createClient(
      this.config.getOrThrow('SUPABASE_URL'),
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
}
