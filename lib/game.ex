defmodule Blackjack.Game do
  
  defstruct [:deck, :state, player_points: 0, dealer_points: 0, dealer: [], player: []]
  
end