with Ada.Unchecked_Conversion;
with monte_carlo_tree_search;

package body connect4 is

   function get_available_cols (game : game_states) return available_cols is
      avail_cols : available_cols := (others => true);
   begin
      for c in col_index'range loop
         declare
            counter : integer := 0;
         begin
            for r in row_index'range loop
               if game (r, c) /= empty then
                  counter := counter + 1;
               end if;
            end loop;

            if counter = row_index'last then
               avail_cols (c) := false;
            end if;
         end;

      end loop;
      return avail_cols;
   end;

   function get_number_available_cols (avail_cols : available_cols) return natural is
      counter : natural := 0;
   begin
      for i in avail_cols'range loop
         if avail_cols (i) then
            counter := counter + 1;
         end if;
      end loop;
      return counter;
   end;

   function play_turn (game : in out game_states; gs : game_state; ci : col_index) return boolean is

      function find_row_in_col (row : out row_index) return boolean is
      begin
         for r in reverse row_index'range loop
            if game (r, ci) = empty then
               row := r;
               return true;
            end if;
         end loop;
         return false;
      end;

      ri : row_index := row_index'last;
      find_result : constant boolean := find_row_in_col (ri);
   begin
      if find_result then
         if game (ri, ci) = empty then
            game (ri, ci) := gs;
            return true;
         end if;
      end if;
      return false;
   end;

   protected body player_turn is
      procedure switch_player is
      begin
         if pt = x then
            pt := o;
         else
            pt := x;
         end if;
      end;

      function get_player_turn return player_color is
      begin
         return pt;
      end;
   end;

   function play_ai return boolean is
      col : col_index;
      ai_color : player_color := x;
   begin
      if human_color = x then
         ai_color := o;
      end if;
      col := monte_carlo_tree_search.run(game_ss, 1000, ai_color);
      return play_turn (game_ss, ai_color, col);
   end;

   type win_sequences is array(1..69, 1..4) of integer;

   ws : constant win_sequences :=
     ((0,1,2,3),
      (1,2,3,4),
      (2,3,4,5),
      (3,4,5,6),
      (7,8,9,10),
      (8,9,10,11),
      (9,10,11,12),
      (10,11,12,13),
      (14,15,16,17),
      (15,16,17,18),
      (16,17,18,19),
      (17,18,19,20),
      (21,22,23,24),
      (22,23,24,25),
      (23,24,25,26),
      (24,25,26,27),
      (28,29,30,31),
      (29,30,31,32),
      (30,31,32,33),
      (31,32,33,34),
      (35,36,37,38),
      (36,37,38,39),
      (37,38,39,40),
      (38,39,40,41),
      (0,7,14,21),
      (7,14,21,28),
      (14,21,28,35),
      (1,8,15,22),
      (8,15,22,29),
      (15,22,29,36),
      (2,9,16,23),
      (9,16,23,30),
      (16,23,30,37),
      (3,10,17,24),
      (10,17,24,31),
      (17,24,31,38),
      (4,11,18,25),
      (11,18,25,32),
      (18,25,32,39),
      (5,12,19,26),
      (12,19,26,33),
      (19,26,33,40),
      (6,13,20,27),
      (13,20,27,34),
      (20,27,34,41),
      (3,9,15,21),
      (4,10,16,22),
      (10,16,22,28),
      (5,11,17,23),
      (11,17,23,29),
      (17,23,29,35),
      (6,12,18,24),
      (12,18,24,30),
      (18,24,30,36),
      (13,19,25,31),
      (19,25,31,37),
      (20,26,32,38),
      (3,11,19,27),
      (2,10,18,26),
      (10,18,26,34),
      (1,9,17,25),
      (9,17,25,33),
      (17,25,33,41),
      (0,8,16,24),
      (8,16,24,32),
      (16,24,32,40),
      (7,15,23,31),
      (15,23,31,39),
      (14,22,30,38));

   function found_winner (game : game_states) return game_output is
      counter : integer;
      ref_gs : game_state := empty;
      draw_counter : integer := 0;

      function get_position_from_index (index : integer) return position is
         row : constant integer := integer(float'ceiling(float(index + 1)/7.0));
         col : constant integer := (index mod 7) + 1;
         pos : constant position := (row, col);
      begin
         return pos;
      end;

      pos : position;
   begin
      for i in ws'range (1) loop
         counter := 0;
         for j in ws'range (2) loop
            pos := get_position_from_index(ws(i,j));
            if counter = 0 then
               ref_gs := game(pos.row, pos.col);
            end if;
            if game(pos.row, pos.col) = ref_gs then
               counter := counter + 1;
            end if;
         end loop;
         if counter = 4 and ref_gs /= empty then
            return ref_gs;
         end if;
      end loop;

      for row in game'range (1) loop
         for col in game'range (2) loop
            if game (row, col) /= empty then
               draw_counter := draw_counter + 1;
            end if;
         end loop;
      end loop;

      if draw_counter = row_index'last * col_index'last then
         return draw;
      end if;

      return empty;
   end;

   procedure update is
      function keyboard_state_to_col_index is
        new Ada.Unchecked_Conversion (source => keyboard_state, target => col_index);
      col : constant col_index := keyboard_state_to_col_index (kbd_state);
      result : boolean;
   begin
      if winner = empty then
         if player_turn.get_player_turn = human_color then
            if col'valid then
               declare
                  valid_move : constant boolean := play_turn (game_ss, human_color, col);
               begin
                  if valid_move then
                     player_turn.switch_player;
                  end if;
               end;
            end if;
         else
            result := play_ai;
            player_turn.switch_player;
         end if;
         winner := found_winner (game_ss);
      end if;
   end;

end connect4;
