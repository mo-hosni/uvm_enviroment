//set_response_queue_depth 15
// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
//set_response_queue_error_report_disabled TRUE
//   interface  //
interface intf1();
  	logic clk;
  	logic rst_n;
  	logic[1:15] initial_state;
  	logic in_bit;
  	logic en;
  	logic out_bit;
  	logic scmb_en;
    initial
          clk = 0;
  	always #5 clk = ~clk;
endinterface

package my_pack;
import uvm_pkg::*;
//   sequence_item   //
class my_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(my_sequence_item)
  	logic rst_n;
  	logic[1:15] initial_state;
  	logic in_bit;
  	logic en;
  	logic out_bit;
  	logic scmb_en;
	logic out_ref;
    virtual interface intf1 local_virtual;
    function new(string name = "my_sequence_item",uvm_component parent = null);
    	super.new(name);
    endfunction
   	task print(string s);
		$display("time: %0d ",$time,s);
	endtask
endclass
//   my_sequence_1   //
class my_sequence_1 extends uvm_sequence;
logic [1:1504] in_ref  [1:50];
`uvm_object_utils(my_sequence_1)
function new(string name = "my_sequence_1",uvm_component parent = null);
	super.new(name);
endfunction
my_sequence_item seq_item;
task pre_body;
	seq_item = my_sequence_item::type_id::create("seq_item");
    $readmemb("in.dat", in_ref); 
    this.set_response_queue_error_report_disabled(1);
    //this.get_response_queue_error_report_disabled(1);
endtask
task body;
  for(int j = 1; j < 51; j++)
  begin
  	start_item(seq_item);
		seq_item.rst_n = 0;
  		seq_item.initial_state = 15'b100101010000000;
  		seq_item.in_bit = 0;
  		seq_item.en = 0;
  		//seq_item.out_ref = 0;
	finish_item(seq_item);
	start_item(seq_item);
		seq_item.rst_n = 1;
  		seq_item.initial_state = 15'b100101010000000;
  		seq_item.in_bit = 0;
  		seq_item.en = 0;
  		//seq_item.out_ref = 0;
	finish_item(seq_item);
    for(int i = 1; i <1505; i++)
      begin
          start_item(seq_item);
            seq_item.rst_n = 1;
            seq_item.initial_state = 15'b100101010000000;
            seq_item.in_bit = in_ref[j][i];
            seq_item.en = 1;
          finish_item(seq_item);
      end
  start_item(seq_item);
  seq_item.rst_n = 1;
  seq_item.initial_state = 15'b100101010000000;
  seq_item.in_bit = 1'bx;
  seq_item.en = 1;
  finish_item(seq_item);
  end
  start_item(seq_item);
  seq_item.rst_n = 1;
  seq_item.initial_state = 15'b100101010000000;
  seq_item.in_bit = 1'bx;
  seq_item.en = 1;
  finish_item(seq_item);
endtask
endclass
//    sequencer     //
class my_sequencer extends uvm_sequencer#(my_sequence_item);
	`uvm_component_utils(my_sequencer)
	virtual interface intf1 local_virtual;
	function new(string name = "my_sequencer",uvm_component parent = null);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
      	$display("time: %0d ",$time," my_sequencer: build_phase ");
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	$display("time: %0d ",$time," my_sequencer: connect_phase  ");
	endfunction
	task  run_phase(uvm_phase phase);
		super.run_phase(phase);
      	$display("time: %0d ",$time," my_sequencer: run_phase ");
	endtask
endclass
//     driver     //
class my_driver extends uvm_driver#(my_sequence_item);
    `uvm_component_utils(my_driver)
    my_sequence_item seq_item;
    virtual interface intf1 local_virtual;
    function new(string name = "my_driver", uvm_component parent = null);
    	super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	$display("time: %0d ",$time, " my_driver: build_phase ");
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
    	seq_item = my_sequence_item::type_id::create("seq_item",this);
    endfunction
    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
      	$display("time: %0d ",$time, " my_driver: connect_phase ");
    endfunction
    task run_phase(uvm_phase phase);
    	super.run_phase(phase);
      	$display("time: %0d ",$time," my_driver: run_phase ");
    	forever
    	begin
          @(negedge local_virtual.clk)
          begin
            seq_item_port.get_next_item(seq_item);
    		local_virtual.rst_n <= seq_item.rst_n;
        	local_virtual.initial_state <= seq_item.initial_state;
          	local_virtual.in_bit <= seq_item.in_bit;
          	local_virtual.en <= seq_item.en;
    		//$display("time: %0d ",$time, " driver in_bit: ","%p", local_virtual.in_bit);
          	//$display("time: %0d ",$time, " driver en: ","%p", local_virtual.en);
          	//#1 
            seq_item_port.item_done(seq_item);
          end
    	end
    endtask
endclass
//   monitor   //
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    virtual interface intf1 local_virtual;
    uvm_analysis_port#(my_sequence_item) my_analysis_port ;
    my_sequence_item seq_item;
    function new(string name = "my_monitor",uvm_component parent = null);
        super.new(name,parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      	my_analysis_port = new ("my_analysis_port", this );
        seq_item = my_sequence_item::type_id:: create("seq_item");
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
        $display("time: %0d ",$time," my_monitor: build_phase  ");
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        $display("time: %0d ",$time," my_monitor: connect_phase  ");
    endfunction
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        $display("time: %0d ",$time, " my_monitor: run_phase  ");
        forever
        begin
          @(negedge local_virtual.clk, negedge local_virtual.scmb_en);
          if(local_virtual.scmb_en == 1'b1)
            begin
              seq_item.out_bit = local_virtual.out_bit;
              seq_item.scmb_en = local_virtual.scmb_en;
              //$display("time: %0d ",$time," Monitor out_bit: ", seq_item.out_bit);
              //$display("time: %0d ",$time," Monitor scmb_en: ", seq_item.scmb_en);
              my_analysis_port.write(seq_item);
            end
        end
   	    $display("time: %0d ",$time," my_monitor: run_phase");
    endtask
endclass
//   scoreboard     //
class my_scoreboard extends uvm_scoreboard;
  logic [1:1504] out_ref [1:50];
  logic out_ref2 [$]; 
  logic [1:1504] out_ref3;
  logic temp;
  logic error;
   `uvm_component_utils(my_scoreboard)
    uvm_analysis_imp #(my_sequence_item , my_scoreboard ) my_analysis_imp;
    function new(string name = "my_scoreboard", uvm_component parent = null);
    	super.new(name,parent);
    endfunction
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
        my_analysis_imp = new("my_analysis_imp",this);
      	$display("time: %0d ",$time," my_scoreboard: build phase ");
    endfunction
    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	$display("time: %0d ",$time," my_scoreboard: connect_phase  ");
    endfunction
    task run_phase(uvm_phase phase);
      	super.run_phase(phase);
        $readmemb("out.dat", out_ref);
      	$display("time: %0d ",$time," my_scoreboard: run_phase ");
    endtask
    task write(my_sequence_item seq_item);
      //$display("time: %0d ", $time, " scoreboard: ", seq_item.out_bit);
      out_ref2.push_back(seq_item.out_bit);
    endtask
  	function void check_phase(uvm_phase phase);
    	super.check_phase(phase);
      error = 0;
      	//$display("time: %0d ", $time, " scoreboard check: ", out_ref2);
      	//$display("time: %0d ", $time, " scoreboard check: %b", out_ref[1][1:8]);
      for(int j = 1; j < 51; j++)
        begin
          for(int i = 1; i < 1505; i++)
          begin
            temp = out_ref2.pop_front;
            if(temp == out_ref[j][i])
              begin
                //$display("Scoreboard: SUCCESS. Frame [%0d]", j, " Element [%0d]", i, ". OUT=%b",temp,". REF=%b",out_ref[j][i]);
              end
          	else
              begin
                //$display("Scoreboard: FAIL.    Frame [%0d]", j, " Element [%0d]", i, ". OUT=%b",temp,". REF=%b", out_ref[j][i]);
                error = 1;
              end
          end
          if(!error)
            $display("Scoreboard: SUCCESS. Frame [%0d]", j);
          else
            begin
              $display("Scoreboard: FAIL. Frame [%0d]", j);
              error = 0;
            end
        end
  	endfunction
endclass
//     subscriber    //
class my_subscriber extends uvm_subscriber#(my_sequence_item);
	`uvm_component_utils(my_subscriber)
	uvm_analysis_imp #(my_sequence_item , my_subscriber) my_analysis_imp;
	function new(string name = "my_subscriber",uvm_component parent = null);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		my_analysis_imp = new("my_analysis_imp",this);
		$display("time: %0d ",$time," my_subscriber: build_phase  ");
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		$display("time: %0d ",$time," my_subscriber: connect_phase  ");
	endfunction

    task run_phase(uvm_phase phase);
    	super.run_phase(phase);
      $display("time: %0d ",$time," my_subscriber: run_phase ");
    endtask
    function void write(my_sequence_item t);
      //t.print(" subscriber: hello");
    endfunction
endclass
//   agent   //
class my_agent extends uvm_agent;
	`uvm_component_utils(my_agent)
	virtual interface intf1 local_virtual;
	my_sequencer my_sequencer_1;
	my_driver my_driver_1;
	my_monitor my_monitor_1;
	uvm_analysis_port#(my_sequence_item) my_analysis_port;
	function new(string name = "my_agent",uvm_component parent = null);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		my_sequencer_1 = my_sequencer::type_id::create("my_sequencer_1",this);
		my_driver_1 = my_driver::type_id::create("my_driver_1",this);
		my_monitor_1 = my_monitor::type_id::create("my_monitor_1",this);
		my_analysis_port = new("my_analysis_port", this);
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
     	uvm_config_db#(virtual intf1)::set(this,"my_sequencer_1","vif", local_virtual);
      	uvm_config_db#(virtual intf1)::set(this,"my_driver_1","vif", local_virtual);
      	uvm_config_db#(virtual intf1)::set(this,"my_monitor_1","vif", local_virtual);
      	$display("time: %0d ",$time," my_agent: build_phase ");
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	$display("time: %0d ",$time," my_agent: connect_phase ");
		my_driver_1.seq_item_port.connect(my_sequencer_1.seq_item_export);
      	//my_monitor_1.my_analysis_port.connect(my_analysis_port);
	endfunction
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
      	$display("time: %0d ",$time," my_agent: run_phase ");
	endtask
endclass  
//    env    //
class my_env extends uvm_env;
	`uvm_component_utils(my_env)
	virtual interface intf1 local_virtual;
	my_agent my_agent_1;
    my_subscriber my_subscriber_1;
	my_scoreboard my_scoreboard_1;
	function new(string name = "my_env",uvm_component parent = null);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		my_agent_1 = my_agent::type_id::create("my_agent_1",this);
      	my_subscriber_1 = my_subscriber::type_id::create("my_subscriber_1",this);
		my_scoreboard_1 = my_scoreboard::type_id::create("my_scoreboard_1",this);
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
        uvm_config_db#(virtual intf1)::set(this,"my_agent_1","vif", local_virtual);
     	uvm_config_db#(virtual intf1)::set(this,"my_subscriber_1","vif",local_virtual);
		uvm_config_db#(virtual intf1)::set(this,"my_scoreboard_1","vif",local_virtual);
      	$display("time: %0d ",$time," my_env: build_phase ");
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	my_agent_1.my_monitor_1.my_analysis_port.connect(my_scoreboard_1.my_analysis_imp);
      	my_agent_1.my_monitor_1.my_analysis_port.connect(my_subscriber_1.analysis_export);
      	$display("time: %0d ",$time," my_env: connect_phase ");
	endfunction
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
      	$display("time: %0d ",$time," my_env: run_phase ");
	endtask
endclass
//     test     //
class my_test extends uvm_test;
	`uvm_component_utils(my_test)
	virtual interface intf1 local_virtual;
	my_env my_env_1;
	my_sequence_1 sequence_inst_1;
	function new(string name = "my_test",uvm_component parent = null);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		my_env_1 = my_env::type_id::create("my_env_1",this);
		sequence_inst_1 = my_sequence_1::type_id::create("sequence_inst_1",this);
      	uvm_config_db#(virtual intf1)::get(this,"","vif", local_virtual);
		uvm_config_db#(virtual intf1)::set(this,"my_env_1","vif",local_virtual);
     	$display("time: %0d ",$time," my_test: build_phase ");
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	$display("time: %0d ",$time," my_test: connect_phase ");
	endfunction
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
      	$display("time: %0d ",$time," my_test: run_phase");
			sequence_inst_1.start(my_env_1.my_agent_1.my_sequencer_1);
		phase.drop_objection(this);
	endtask
endclass

endpackage
//    Top    //
module uvm_top();
intf1 in1();
import uvm_pkg::*;
import my_pack::*;
//dut
BB_scrambler dut (in1.clk,
               in1.rst_n,
    		   in1.initial_state,
               in1.in_bit,
               in1.en,
               in1.out_bit,
               in1.scmb_en
            );
//
initial 
begin
  	//set_response_queue_depth 15
	$dumpfile("dump.vcd"); 
	$dumpvars;
	uvm_config_db#(virtual intf1)::set(null,"uvm_test_top","vif",in1);
	run_test("my_test");
end
endmodule