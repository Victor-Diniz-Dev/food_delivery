-- Inserindo pratos iniciais no catálogo

insert into public.dishes (name, description, price_cents, image_url, tags) values
('Cheeseburger Clássico', 'Pão brioche, blend artesanal de 180g, cheddar e molho da casa.', 3200, 'https://picsum.photos/seed/cheese/640/480', '{burger,combo}'),
('Veggie Bowl', 'Base de quinoa, legumes grelhados e molho tahine.', 2900, 'https://picsum.photos/seed/veggie/640/480', '{veggie,leve}'),
('Pizza Margherita', 'Molho de tomate, mozzarella fresca e manjericão.', 4500, 'https://picsum.photos/seed/pizza/640/480', '{pizza,italiana}'),
('Salmão Grelhado', 'Filé de salmão com purê de batatas e legumes.', 5400, 'https://picsum.photos/seed/salmon/640/480', '{peixe,leve}'),
('Spaghetti Carbonara', 'Massa artesanal, pancetta, ovo e queijo pecorino.', 4800, 'https://picsum.photos/seed/carbonara/640/480', '{massa,italiana}');
