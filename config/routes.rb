Spree::Sunspot::Engine.routes.draw do
end

Spree::Core::Engine.routes.prepend do
  match "/q" => "home#filter"
  match "/products/q" => "products#filter"
  match "/:id/q" => "taxons#filter", :constraints => { :id => Regexp.new('(' + Spree::Taxon.all.collect { |b| b.linkname rescue b.permalink }.join('|') + ')') }
end
