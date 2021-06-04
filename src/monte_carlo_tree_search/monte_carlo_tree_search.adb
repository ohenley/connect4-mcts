with ada.numerics.generic_elementary_functions;
with ada.containers.multiway_trees;
with ada.containers; use ada.containers;
with ada.numerics.discrete_random;

package body monte_carlo_tree_search is

   subtype safe_float is float range float'range;

   type state is
      record
         gss        : game_states;
         ucb        : safe_float     := 0.0;
         value      : safe_float     := 0.0;
         visits     : natural        := 0;
         color      : player_color;
      end record;

   package trees is new ada.containers.multiway_trees (state);
   use trees;

   function ucb1 (child : state; parent : state) return safe_float is
      package math is new ada.numerics.generic_elementary_functions (safe_float);
      exploitation, exploration, ln_nbr_visits : safe_float;
   begin
      if child.visits = 0 then
         return safe_float'last;
      else
         ln_nbr_visits := math.log(safe_float(parent.visits));
         exploitation := child.value / safe_float(child.visits);
         exploration := 2.0 * math.sqrt (ln_nbr_visits/safe_float(child.visits));
         return exploitation + exploration;
      end if;
   end;

   function run (game : game_states; nbr_iterations : natural; perspective : player_color) return col_index is
      t : tree;

      function get_best_child_ucb1 (c : cursor) return cursor is
         best_ucb1 : safe_float := safe_float'first;
         best_ucb1_cursor : cursor;
         current_ucb1 : safe_float;
      begin
         for it in t.iterate_children(c) loop
            current_ucb1 := ucb1 (element (it), element (c));
            if current_ucb1 > best_ucb1 then
               best_ucb1 := current_ucb1;
               best_ucb1_cursor := it;
            end if;
         end loop;
         return best_ucb1_cursor;
      end;

      procedure roll_turn (gss : in out game_states; color : player_color) is
         package rand_col is new ada.numerics.discrete_random(col_index);
         use rand_col;
         gen : generator;
         avail_cols : constant available_cols := get_available_cols(gss);
         nbr_avail_cols : constant natural := get_number_available_cols(avail_cols);
      begin
         reset(gen);
         if nbr_avail_cols > 0 then
            while not play_turn (gss, color, random(gen)) loop
               null;
            end loop;
         end if;
      end;

      function switch_player (pt : player_color) return player_color is
      begin
         if pt = x then
            return o;
         end if;
         return x;
      end;

      function rollout (c : cursor; persp : player_color) return game_output is
         gss : game_states := element (c).gss;
         player_turn : player_color;
         winner : game_output;
      begin
         -- whos turn
         if (depth (c) mod 2) = 0 then
            player_turn := persp;
         else
            player_turn := switch_player (persp);
         end if;

         -- maybe we are done
         winner := found_winner (gss);
         while winner = empty loop
            roll_turn (gss, player_turn);
            player_turn := switch_player (player_turn);
            winner := found_winner (gss);
         end loop;
         return winner;
      end;

      procedure backpropagate (c : in out cursor; winner : game_output; persp : player_color) is
         delta_point : safe_float;
      begin
         while depth (c) > 2 loop
            -- increment visit
            t (c).visits := element(c).visits + 1;
            -- attribute point value
            if (depth (c) mod 2) = 0 then
               if persp = winner then
                  delta_point := 1.0;
               else
                  delta_point := -1.0;
               end if;
            else
               if persp = winner then
                  delta_point := -1.0;
               else
                  delta_point := 1.0;
               end if;
            end if;
            t (c).value := element (c).value + delta_point;
            -- move up
            c := parent (c);
         end loop;
         t (c).visits := element(c).visits + 1;
      end;

      procedure expand (c : cursor; persp : player_color) is
         avail_cols : constant available_cols := get_available_cols(element(c).gss);
         color : player_color;
      begin
         for col in avail_cols'range loop
            if avail_cols (col) then
               if (depth (c) mod 2) = 0 then
                  color := switch_player (persp);
               else
                  color := persp;
               end if;
               declare
                  s : state;
                  gss : game_states := element (c).gss;
               begin
                  while not play_turn (gss, color, col) loop
                     null;
                  end loop;
                  s.gss := gss;
                  append_child (t, c, s);
               end;
            end if;
         end loop;
      end;

      cur         : cursor := t.root;
      init_s      : state;
      go          : game_output;
   begin
      clear (t);
      init_s.gss := game;
      append_child (t, cur, init_s);
      cur := first_child (cur);

      for it in 1 .. nbr_iterations loop
         while not is_leaf (cur) loop
            cur := get_best_child_ucb1(cur);
         end loop;
         if element (cur).visits = 0 then
            go := rollout (cur, perspective);
         else
            expand (cur, perspective);
            cur := first_child (cur);
            go := rollout (cur, perspective);
         end if;
         backpropagate(cur, go, perspective);
      end loop;

      declare
         best_col    : col_index;
         most_visits : natural := 0;
         index       : col_index := col_index'first;
      begin
         for it in t.iterate_children(cur) loop
            if element (it).visits > most_visits then
               most_visits := element (it).visits;
               best_col := index;
            end if;
            if index /= col_index'last then
               index := index + 1;
            end if;
         end loop;
         return best_col;
      end;
   end;

end monte_carlo_tree_search;
