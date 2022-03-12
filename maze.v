`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Plesca Natalia
// 
// Create Date:    19:32:08 12/03/2021 
// Design Name: 
// Module Name:    maze 
// Project Name:  Tema2
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze #(parameter maze_width = 6)(
		input 		       				 clk,
		input 		[maze_width - 1:0] starting_col, starting_row, 	// indicii punctului de start
		input  			  	 				 maze_in, 			// ofera informa?ii despre punctul de coordonate [row, col]
		output reg 	[maze_width - 1:0] row, col,	 		// selecteaza un rand si o coloana din labirint
		output reg			  				 maze_oe,			// output enable (activeaza citirea din labirint la randul si coloana date) - semnal sincron	
		output reg			   			 maze_we, 			// write enable (activeaza scrierea in labirint la randul si coloana date) - semnal sincron
		output reg			  				 done);		 	// iesirea din labirint a fost gasita; semnalul ramane activ 
	
	
`define state1      		0
`define state2          1
`define state3          2
`define state4          3
`define state5          4
`define state6          8
`define stop            9




reg [maze_width -1:0] row_copy, col_copy; 

reg  [7:0] dd;  

reg [4:0] state, next_state ; 	

always @(posedge clk) begin
								if(done == 0) state <= next_state;
							 end

always @(*) begin
					 next_state = `state1;
					 maze_we = 0;
					 maze_oe = 0;
					 done = 0;
					 
					 case(state)
							`state1 : begin
											dd = 'b01000001;//fie deplasarea initiala spre dreapta
											maze_we = 1; //activez maze write enable ca sa scriu 2 pe pozitia de start
											row = starting_row;
											col = starting_col;
											row_copy = starting_row; //salvez randul si coloana in copii
											col_copy = starting_col;

											next_state = `state2;
										 end


							`state2 : begin
											case(dd)
												'b01000001: col = col + 1; //drepta
												'b01000010: row = row + 1 ; //jos 
												'b01000011: col = col - 1; //stanga
												'b01000100: row = row - 1; //sus
											endcase
											maze_oe = 1;
											next_state =  `state3;

										end


							`state3: begin
											if(maze_in == 0) begin //trec la alta pozitie si salvez coordonatele in copii
													col_copy = col;
													row_copy = row;
													maze_we = 1;

													next_state = `state4;
											end

											if(maze_in == 1) begin //am dat de perete;
													dd = dd + 1; //incerc o alta directie
													col = col_copy;
													row = row_copy;

													next_state = `state2;

											end

										end


							`state4: begin //verific mereu partea dreapta si setez pozitia
												case(dd)
													'b01000001: begin //dreapta
															row_copy = row; //salvez pozitia
															row = row + 1; //verific in jos
														end
														
													'b01000010: begin //jos
															col_copy = col; 
															col = col - 1; //verific in stanga
														end
														
													'b01000011: begin //stanga
															row_copy = row; 
															row = row - 1; //verific in sus
														end
												
													'b01000100: begin //sus
															col_copy = col;
															col = col + 1; // verific in dreapta
														end
														
												endcase
												maze_oe = 1;
												next_state = `state5;

										end

							
							`state5: begin //verific ce am pe pozitie 
											case(dd)
												'b01000001: begin //deplasare dreapta
														//verific ce am jos
														if(maze_in == 1) begin
																					row = row_copy; //ma reintorc
																					col_copy = col; //salvez pozitia
																					col = col + 1; //ma deplasez dreapta
																			  end

														if(maze_in == 0) begin //raman si salvez coordonatele in copii
																					row_copy = row;
																					col_copy = col;
																					dd = 'b01000010; //schimb cu deplasare in jos
																				end

													end

												'b01000010: begin //deplasare jos
														if(maze_in == 1) begin
																					col = col_copy; // ma reintorc
																					row_copy = row; //salvez pozitia
																					row = row + 1; //ma deplasez jos
																				end

														if(maze_in == 0) begin //raman si salvez coordonatele in copi
																					col_copy = col;
																					row_copy = row;
																					dd = 'b01000011; //schimb cu deplasare stanga
																				end

													end
													
												'b01000011: begin //deplasarea stanga

														if(maze_in == 1) begin
																					row = row_copy; //ma reintorc
																					col_copy = col; //salvez pozitia
																					col = col - 1; //ma deplasez stanga
																				end

														if(maze_in == 0) begin //raman si salvez coordoatele in copi
																					row_copy = row;
																					col_copy = col;
																					dd = 'b01000100; //schimb cu deplasare sus
																				end

													end

												'b01000100: begin //deplasare sus
														if(maze_in == 1) begin
																				col = col_copy; //ma reintorc
																				row_copy = row; //salvez pozitia
																				row = row - 1;//ma deplasez in sus
																				end


														if(maze_in == 0) begin //raman si salvez noile coordonate in copi
																				col_copy = col;
																				row_copy = row;
																				dd = 'b01000001; // schimb cu deplasare dreapta
																			  end

													end
													
											endcase
											maze_oe = 1;
											next_state = `state6;
											
										end
									 
							`state6: begin  //verific ce am pe pozitia curenta si daca ma aflu pe margine
											if(maze_in == 0)  begin
																		if(col == 0 || col == 63 || row == 0 || row == 63) begin
																																				maze_we = 1;
																																				next_state = `stop;
																																			end

																		else begin //daca am 0 dar nu sunt pe margine
																					col_copy = col; //salvez poz in copie
																					row_copy = row;
																					maze_we = 1;
																					next_state = `state4;
																				end
																	end

											if(maze_in == 1) begin //am dat de perete deci schimb directia de deplasare
																		row = row_copy;
																		col = col_copy;
																		case(dd) //ne rotim la 180 grade
																			'b01000001: dd = 'b01000011;
																			'b01000010: dd = 'b01000100;
																			'b01000011: dd = 'b01000001;
																			'b01000100: dd = 'b01000010;
																		endcase

																		next_state = `state4;
																	end

										end


							`stop: begin
										done = 1; //Uraaa am scapat din labirint! :D
									 end

							

					endcase

				end

endmodule 