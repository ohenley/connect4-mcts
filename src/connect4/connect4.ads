package connect4 is

   subtype row_index is integer range 1 .. 6;
   subtype col_index is integer range 1 .. 7;
   type position is
      record
         row : row_index;
         col : col_index;
      end record;

   type game_output is (x, o, empty, draw);
   subtype game_state is game_output range x .. empty;
   subtype player_color is game_state range x .. o;
   type game_states is array(row_index, col_index) of game_state;

   type keyboard_state is (alpha1, alpha2, alpha3, alpha4, alpha5, alpha6, alpha7, invalid);

   type available_cols is array(col_index) of boolean;

   function get_available_cols (game : game_states) return available_cols;
   function get_number_available_cols (avail_cols : available_cols) return natural;
   function play_turn (game : in out game_states; gs : game_state; ci : col_index) return boolean;

   game_ss : game_states := (others => (others => empty));
   kbd_state : keyboard_state := invalid;
   game_out : game_output := draw;
   human_color : player_color := x;
   winner : game_output := empty;

   protected player_turn is
      procedure switch_player;
      function get_player_turn return player_color;
   private
      pt : player_color := x;
   end;

   function found_winner (game : game_states) return game_output;

   procedure update;

end connect4;
