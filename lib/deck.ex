defmodule Blackjack.Deck do
  
  def suits do
    ["♠", "♥", "♦", "♣"]
  end
  
  def cards do
    ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
  end
  
  def initial do
    for n <- cards(), s <- suits() do
      {n, s}
    end
  end
  
  def compute_points deck do
    points_without_aces = compute_cards(deck)
    compute_aces(deck, points_without_aces)
  end
  
  def compute_cards deck do
    deck
    |> Enum.reject(fn {card, _} -> card == "A" end)
    |> Enum.reduce(0, fn ({card, _}, points) ->
      cond do
        card in ["J", "Q", "K"] ->
          points + 10
        true ->
          points + String.to_integer(card)
      end
    end)
    
  end
  
  def compute_aces deck, points do
    number_of_aces = Enum.count(deck, fn {card, _} -> card == "A" end)
    cond do
      number_of_aces >= 1 ->
        points = points + number_of_aces - 1
        if points > 10, do: points + 1, else: points + 11
      true ->
        points
    end 
  end
  
end