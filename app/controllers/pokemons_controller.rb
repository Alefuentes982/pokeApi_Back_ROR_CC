class PokemonsController < ApplicationController
  require 'net/http'

  def import
    url = 'https://pokeapi.co/api/v2/pokemon?limit=150'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    pokemons = JSON.parse(response)['results']

    pokemons.each do |pokemon_data|
      pokemon_url = URI(pokemon_data['url'])
      pokemon_response = Net::HTTP.get(pokemon_url)
      pokemon_info = JSON.parse(pokemon_response)

      types = pokemon_info['types'].map { |t| t['type']['name'] }

      Pokemon.create(
        name: pokemon_info['name'],
        types: types.join(','),
        image: pokemon_info['sprites']['front_default'],
        captured: false
      )
    end

    render json: { message: 'Pokemones importados' }, status: :ok
  end

  def index
    page = params[:page] || 1
    search_text = params[:name] || params[:type]

    if search_text.present?

      pokemons = Pokemon.where('name LIKE ? OR types LIKE ?', "%#{search_text}%", "%#{search_text}%")
      total_pages = 1
    else

      pokemons = Pokemon.all
      total_pages = (pokemons.count / 20.0).ceil
      pokemons = pokemons.page(page).per(20)
    end

    render json: {
      pokemons:,
      total_pages:,
      current_page: page
    }, status: :ok
  end

  def capture
    pokemon = Pokemon.find(params[:id])
    captured_pokemons = Pokemon.where(captured: true).order(:capture_date)

    if captured_pokemons.count >= 6
      oldest_pokemon = captured_pokemons.first
      oldest_pokemon.update(captured: false)
    end

    pokemon.update(captured: true, capture_date: Time.now)

    render json: { message: 'Pokémon capturado' }, status: :ok
  end

  def captured
    captured_pokemons = Pokemon.where(captured: true)
    render json: captured_pokemons, status: :ok
  end

  def destroy
    pokemon = Pokemon.find(params[:id])
    pokemon.update(captured: false)

    render json: { message: 'Pokémon liberado' }, status: :ok
  end
end
