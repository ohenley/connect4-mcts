with connect4; use connect4;

package monte_carlo_tree_search is
   function run (game : game_states; nbr_iterations : natural; perspective : player_color) return col_index;
end monte_carlo_tree_search;

