// supabase/functions/place-order/index.ts
// Função Edge Function para criar pedidos

import 'jsr:@supabase/functions-js/edge-runtime.d.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { user_id, items } = await req.json();

    if (!user_id || !Array.isArray(items) || items.length === 0) {
      return new Response(JSON.stringify({ error: 'Parâmetros inválidos.' }), {
        status: 400,
        headers: corsHeaders,
      });
    }

    // calcula o total
    const total = items.reduce(
      (acc: number, i: { quantity: number; unit_price_cents: number }) =>
        acc + i.quantity * i.unit_price_cents,
      0
    );

    // insere o pedido
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey =
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ||
      Deno.env.get('SUPABASE_ANON_KEY');
    const { createClient } = await import('npm:@supabase/supabase-js@2');
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { data: order, error: err1 } = await supabase
      .from('orders')
      .insert({ user_id, status: 'pending', total_cents: total })
      .select()
      .single();

    if (err1) throw err1;

    // insere os itens
    const orderItems = items.map((i) => ({
      order_id: order.id,
      dish_id: i.dish_id,
      quantity: i.quantity,
      unit_price_cents: i.unit_price_cents,
    }));

    const { error: err2 } = await supabase.from('order_items').insert(orderItems);
    if (err2) throw err2;

    return new Response(JSON.stringify({ order_id: order.id, total_cents: total }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 201,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: corsHeaders,
    });
  }
});
