with connect4; use connect4;
with game_interface; use game_interface;
with ada.text_io;

with monte_carlo_tree_search; use monte_carlo_tree_search;

procedure tests is

   procedure print_avail_cols (ac: available_cols) is
   begin
      for i in ac'range loop
         ada.text_io.put(ac(i)'image & ", ");
      end loop;
      ada.text_io.put_line("");
   end;

   procedure test_column_full is
      gss : game_states := ((o, empty, empty, empty, empty, empty, empty),
                            (x, x, empty, empty, empty, empty, empty),
                            (o, o, o, empty, empty, empty, empty),
                            (x, x, x, x, empty, empty, empty),
                            (o, o, o, o, o, empty, empty),
                            (x, x, x, x, x, x, empty));
      ac : available_cols := get_available_cols(gss);
   begin
      ada.text_io.put_line ("test_column_full :");
      print_avail_cols (ac);
   end;


   procedure test_play_column_full is
      gss : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                            (empty, empty, empty, empty, empty, empty, empty),
                            (empty, empty, empty, empty, empty, empty, empty),
                            (empty, empty, empty, empty, empty, empty, empty),
                            (empty, empty, empty, empty, empty, empty, empty),
                            (empty, empty, empty, empty, empty, empty, empty));

      turn_legit : boolean;

      procedure play_report_turn (gs : game_State) is
         ac : available_cols;
      begin
         turn_legit := play_turn (gss, gs, col_index'last-2);
         ada.text_io.Put_Line ("turn legit: " & turn_legit'image);
         ac := get_available_cols(gss);
         print_avail_cols (ac);
      end;

   begin
      ada.text_io.put_line ("test_play_column_full :");

      play_report_turn (x);
      play_report_turn (o);
      play_report_turn (x);
      play_report_turn (o);
      play_report_turn (x);
      play_report_turn (o);

      play_report_turn (x); -- should fail

   end;

   procedure test_get_slot_state is
      gs61 : game_state := get_slot_state (6, 1);
      gs62 : game_state := get_slot_state (6, 2);
   begin
      ada.text_io.put_line ("test_get_slot_state :");

      ada.text_io.Put_Line(gs61'image);
      ada.text_io.Put_Line(gs62'image);
   end;

   procedure test_row_winner is
      gss1 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (    o,     o,     o,     o, empty, empty, empty));
      winner : game_output := found_winner (gss1);
   begin
      ada.text_io.put_line ("test_row_winner :");
      if winner /= empty then
         ada.text_io.put_line(winner'image & " wins!");
      end if;
   end;

   procedure test_col_winner is
      gss1 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty,     x, empty),
                             (empty, empty, empty, empty, empty,     x, empty),
                             (empty, empty, empty, empty, empty,     x, empty),
                             (empty, empty, empty, empty, empty,     x, empty),
                             (empty, empty, empty, empty, empty, empty, empty));
      winner : game_output := found_winner (gss1);
   begin
      ada.text_io.put_line ("test_col_winner :");
      if winner /= empty then
         ada.text_io.put_line(winner'image & " wins!");
      end if;
   end;

   procedure test_diag_winner is
      gss1 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty,     x, empty),
                             (empty, empty, empty, empty,     x, empty, empty),
                             (empty, empty, empty,     x, empty, empty, empty),
                             (empty, empty,     x, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty));
      winner : game_output := found_winner (gss1);
   begin
      ada.text_io.put_line ("test_diag_winner :");
      if winner /= empty then
         ada.text_io.put_line(winner'image & " wins!");
      end if;
   end;

   procedure test_monte_carlo is
      gss1 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (    x,     x,     x, empty, empty, empty, empty));

      gss2 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (    o, empty, empty, empty, empty, empty, empty),
                             (    o, empty, empty, empty, empty, empty, empty),
                             (    o, empty, empty, empty, empty, empty, empty));

      gss3 : game_states := ((empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty),
                             (empty, empty, empty, empty,     x, empty, empty),
                             (empty, empty, empty,     x, empty, empty, empty),
                             (empty, empty,     x, empty, empty, empty, empty),
                             (empty, empty, empty, empty, empty, empty, empty));
      col : col_index;
   begin
      ada.text_io.put_line ("test_monte_carlo :");
      col := run (gss1, 1000, x);
      ada.text_io.put_line ("gss1 :" & col'image);
      col := run (gss2, 1000, o);
      ada.text_io.put_line ("gss2 :" & col'image);
      col := run (gss3, 1000, x);
      ada.text_io.put_line ("gss3 :" & col'image);
   end;

begin
   test_column_full;
   test_play_column_full;
   test_get_slot_state;
   test_row_winner;
   test_col_winner;
   test_diag_winner;
   test_monte_carlo;
end;
