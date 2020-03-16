defmodule Blackjack do
  
  alias Blackjack.Game
  alias Blackjack.Deck
  
  def new_game do
    %Game{deck: Deck.initial()}
  end
  
  def start do
    new_game()
    |> play()
  end
  
  def play %Game{state: state} = game do
    case state do
      :player_turn ->
        game
        |> print(:player)
        |> ask_player()
        |> play()
          
      :player_hit ->
        game
        |> hand(:player, 1)
        |> check_player()
        |> play()
      
      :player_won ->
        IO.puts("You win with #{Integer.to_string game.player_points}!")
        
      :player_busted ->
        IO.puts("You got #{Integer.to_string game.player_points} points, you bust!")
        IO.puts("Dealer wins")

      # dealers turn
      :dealer_turn ->
        game
        |> dealer_turn()
        |> play()
        
      :dealer_won ->
        IO.puts("Dealer win with #{Integer.to_string game.dealer_points}!")
        
      :dealer_busted ->
        IO.puts("Dealer got #{Integer.to_string game.dealer_points} points, he busts!")
        IO.puts("You win!")
        
      :draw ->
        IO.puts("Oh no! Draw game.")
      
      # game start
      _ ->
        game
        |> hand(:player, 2)
        |> check_player()
        |> play()
    end
  end
  
  def hand %Game{deck: deck} = game, player, n \\ 1 do
    hand = Enum.take_random deck, n
    %{^player => player_deck} = game
    game
    |> Map.put(:deck, deck -- hand)
    |> Map.put(player, player_deck ++ hand )
    |> put_points()
  end
  
  def dealer_turn %Game{} = game do
    game
    |> hand(:dealer, 2)
    |> print(:dealer)
    |> check_dealer()
  end
  
  def check_dealer game do
    cond do
      game.dealer_points == 21 ->
        Map.put(game, :state, :dealer_won)
      
      game.dealer_points > 21 ->
        Map.put(game, :state, :dealer_busted)
      
      game.dealer_points < 17 ->
        game
        |> hand(:dealer)
        |> print(:dealer)
        |> check_dealer()
      
      game.dealer_points > game.player_points ->
        Map.put(game, :state, :dealer_won)
      
      game.dealer_points < game.player_points ->
        Map.put(game, :state, :player_won)
      
      game.dealer_points == game.player_points ->
        Map.put(game, :state, :draw)
    end
  end
  
  def print game, player do
    {deck, name, points} = case player do
      :player ->
        %Game{player: deck, player_points: points} = game
        {deck, "Player", points}
    
      :dealer ->
        %Game{dealer: deck, dealer_points: points} = game
        {deck, "Dealer", points}
    end
    IO.puts "==== #{name} holds #{Integer.to_string(points)} points ===="
    IO.puts "-> #{name}'s deck:"
    deck
    |> Enum.map(fn ({card, suit}) -> card <> suit end)
    |> Enum.join("-")
    |> IO.puts()
    game
  end
  
  def check_player game do
    cond do
      game.player_points == 21 ->
        Map.put(game, :state, :player_won)
      game.player_points > 21 ->
        Map.put(game, :state, :player_busted)
      true ->
        Map.put(game, :state, :player_turn)
    end
  end
  
  def ask_player game do
    user_choice = 
      IO.gets("Press '1' to hit more cards or '0' to stand.\n")
      |> String.trim()
      
    case user_choice do
      "0" ->
        game
        |> Map.put(:state, :dealer_turn)
      "1" ->
        game
        |> Map.put(:state, :player_hit)
      _ ->
        ask_player(game)
    end
  end
  
  
  def put_points(%Game{player: player, dealer: dealer} = game) do
    game
    |> Map.put(:player_points, Deck.compute_points(player))
    |> Map.put(:dealer_points, Deck.compute_points(dealer))
  end

end
