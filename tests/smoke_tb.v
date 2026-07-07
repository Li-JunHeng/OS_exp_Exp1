`timescale 1ns / 1ps

module smoke_tb();
   reg clk;
   reg rstn;
   reg [4:0] reg_sel;
   wire [31:0] reg_data;

   integer cycles;
   integer max_cycles;
   integer program_words;
   integer foutput;
   integer drain_cycles;
   integer drain_count;
   integer stop_index;
   reg stop_seen;
   reg [31:0] stop_pc;
   reg [31:0] snapshot_pc;
   reg [31:0] snapshot_instr;
   reg [31:0] saved_stop_instr;
   reg [1023:0] program_path;
   reg [1023:0] output_path;

   sccomp U_SCCOMP(
      .clk(clk),
      .rstn(rstn),
      .reg_sel(reg_sel),
      .reg_data(reg_data)
   );

   initial begin
      clk = 1'b0;
      rstn = 1'b1;
      reg_sel = 5'd0;
      cycles = 0;
      drain_count = 0;
      stop_seen = 1'b0;

      if (!$value$plusargs("PROGRAM=%s", program_path))
         program_path = "tests/programs/rv32i_8_instr.dat";
      if (!$value$plusargs("OUTPUT=%s", output_path))
         output_path = "build/results/rv32i_8_instr.txt";
      if (!$value$plusargs("STOP_PC=%h", stop_pc))
         stop_pc = 32'h0000_0048;
      if (!$value$plusargs("MAX_CYCLES=%d", max_cycles))
         max_cycles = 200;
      if (!$value$plusargs("PROGRAM_WORDS=%d", program_words))
         program_words = 15;
      if (!$value$plusargs("DRAIN_CYCLES=%d", drain_cycles))
         drain_cycles = 5;

      #1;
      $readmemh(program_path, U_SCCOMP.U_IM.ROM, 0, program_words - 1);
      saved_stop_instr = U_SCCOMP.U_IM.ROM[stop_pc[11:2]];
      foutput = $fopen(output_path, "w");
      if (foutput == 0) begin
         $display("ASSESS_FAIL: cannot open output file");
         $fatal(1);
      end

      #5;
      rstn = 1'b0;
      #20;
      rstn = 1'b1;
   end

   always begin
      #50 clk = ~clk;
   end

   always @(posedge clk) begin
      if (!rstn) begin
         cycles <= 0;
         drain_count <= 0;
         stop_seen <= 1'b0;
      end else begin
         cycles <= cycles + 1;

         if (U_SCCOMP.U_SCPU.PC_out === 32'hxxxx_xxxx) begin
            $display("ASSESS_FAIL: PC became X at cycle %0d", cycles);
            $fclose(foutput);
            $fatal(1);
         end

         if (!stop_seen && U_SCCOMP.PC + 32'd4 == stop_pc)
            U_SCCOMP.U_IM.ROM[stop_pc[11:2]] = 32'h0000_0013;

         if (!stop_seen && U_SCCOMP.PC == stop_pc) begin
            stop_seen <= 1'b1;
            snapshot_pc <= U_SCCOMP.PC;
            snapshot_instr <= saved_stop_instr;
            drain_count <= 0;
            U_SCCOMP.U_IM.ROM[stop_pc[11:2]] = 32'h0000_0013;
         end else if (stop_seen && U_SCCOMP.U_SCPU.ex_take_branch) begin
            stop_seen <= 1'b0;
            drain_count <= 0;
         end else if (stop_seen) begin
            if (drain_count == 0) begin
               for (stop_index = stop_pc[11:2] + 1; stop_index < stop_pc[11:2] + 8; stop_index = stop_index + 1)
                  U_SCCOMP.U_IM.ROM[stop_index] = 32'h0000_0013;
            end
            drain_count <= drain_count + 1;
         end

         if (stop_seen && drain_count >= drain_cycles) begin
            dump_snapshot();
            $fclose(foutput);
            $display("ASSESS_PASS: drained after stop PC 0x%08h in %0d cycles", stop_pc, cycles);
            $finish;
         end

         if (cycles >= max_cycles) begin
            $display("ASSESS_FAIL: timeout at cycle %0d, PC=0x%08h", cycles, U_SCCOMP.PC);
            $fclose(foutput);
            $fatal(1);
         end
      end
   end

   task dump_snapshot;
      begin
         $fdisplay(foutput, "pc:\t %h", snapshot_pc);
         $fdisplay(foutput, "instr:\t\t %h", snapshot_instr);
         $fdisplay(foutput, "rf00-03:\t %h %h %h %h", 0, U_SCCOMP.U_SCPU.U_RF.rf[1], U_SCCOMP.U_SCPU.U_RF.rf[2], U_SCCOMP.U_SCPU.U_RF.rf[3]);
         $fdisplay(foutput, "rf04-07:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[4], U_SCCOMP.U_SCPU.U_RF.rf[5], U_SCCOMP.U_SCPU.U_RF.rf[6], U_SCCOMP.U_SCPU.U_RF.rf[7]);
         $fdisplay(foutput, "rf08-11:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[8], U_SCCOMP.U_SCPU.U_RF.rf[9], U_SCCOMP.U_SCPU.U_RF.rf[10], U_SCCOMP.U_SCPU.U_RF.rf[11]);
         $fdisplay(foutput, "rf12-15:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[12], U_SCCOMP.U_SCPU.U_RF.rf[13], U_SCCOMP.U_SCPU.U_RF.rf[14], U_SCCOMP.U_SCPU.U_RF.rf[15]);
         $fdisplay(foutput, "rf16-19:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[16], U_SCCOMP.U_SCPU.U_RF.rf[17], U_SCCOMP.U_SCPU.U_RF.rf[18], U_SCCOMP.U_SCPU.U_RF.rf[19]);
         $fdisplay(foutput, "rf20-23:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[20], U_SCCOMP.U_SCPU.U_RF.rf[21], U_SCCOMP.U_SCPU.U_RF.rf[22], U_SCCOMP.U_SCPU.U_RF.rf[23]);
         $fdisplay(foutput, "rf24-27:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[24], U_SCCOMP.U_SCPU.U_RF.rf[25], U_SCCOMP.U_SCPU.U_RF.rf[26], U_SCCOMP.U_SCPU.U_RF.rf[27]);
         $fdisplay(foutput, "rf28-31:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[28], U_SCCOMP.U_SCPU.U_RF.rf[29], U_SCCOMP.U_SCPU.U_RF.rf[30], U_SCCOMP.U_SCPU.U_RF.rf[31]);
      end
   endtask
endmodule
