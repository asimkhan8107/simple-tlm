`include "uvm_macros.svh"

module test;
  import uvm_pkg::*;
  
  // class producer
  class producer extends uvm_component;
    
    uvm_blocking_put_port #(int) put_port;
    
    function new(string name, uvm_component p = null);
      super.new(name, p);
      put_port = new("put_port", this);
    endfunction
    
    task run_phase(uvm_phase phase);
      int randval;
      for(int i = 0; i < 10; i++)
        begin
          randval = $random % 100;
          #10;
          `uvm_info("producer", $sformatf("sending 		%4d", randval), UVM_MEDIUM)
          put_port.put(randval);
        end
    endtask
  endclass:producer
  
  // class consumer
  class consumer extends uvm_component;
    
    uvm_blocking_get_port#(int) get_port;
    
    function new(string name, uvm_component p = null);
      super.new(name, p);
      get_port = new("get_port", this);
    endfunction
    
    task run_phase(uvm_phase phase);
      int val;
      forever
        begin
          get_port.get(val);
          `uvm_info("consumer", $sformatf("receiving 		%4d", val), UVM_MEDIUM)
        end
    endtask
  endclass:consumer
  
  
  // class environment
  class env extends uvm_env;
    producer p;
    consumer c;
    uvm_tlm_fifo #(int) f;
    
    function new(string name = "env");
      super.new(name);
      p = new("producer", this);
      c = new("consumer", this);
      f = new("fifo", this);
      $display("fifo put_export: %s", f.m_name);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      p.put_port.connect(f.put_export);
      c.get_port.connect(f.get_export);
    endfunction
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1000;
      phase.drop_objection(this);
    endtask
  endclass
  
  /// main body of module top
  env e;
  
  initial
    begin
      e = new();
      run_test();
      //$finish();
    end
endmodule
  
          