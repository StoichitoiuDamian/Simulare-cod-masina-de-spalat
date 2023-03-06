library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity masina_spalat is
	port (usa_start:in std_logic;	         --procesul incepe cand se inchide usa de la masina
	clk:in std_logic;
mode:in std_logic;
	                                         --de termperatura ,turatii,mod si timp 
automat:in std_logic_vector(2 downto 0);     --000:spalare rapida
	                                         --001:camasi 
	 										 --010:culori inchise
	 										 --011:rufe murdare
											 --100:anti alergic	
clatire :in std_logic;
prespalare :in std_logic);										 				  
	
end masina_spalat;

architecture arh1 of masina_spalat is 	 

signal temperatura, turatii: std_logic_vector (1 downto 0); --30-"00"   800-"00"
                                                 		    --40-"01"	1000-"01"	
                                                            --60-"10"	1200-"10"
                                                            --90-"11" 

type etape is (	st0 , pres , sprin , cltsup , clt , cent ); --noul tip pentru etapele spalarii

signal state, nextstate :etape;			                    --semnale de tipul "etape"
signal timp : natural := 0;
signal ssel_out: std_logic_vector(7 downto 0); 
type grade is (t30,t40,t60,t90);
type turatie is (tur800,tur1000,tur1200);
signal temp : grade; 
signal stur:turatie; 
begin 
   
	
proces0: process (mode, automat,temperatura,turatii,prespalare,clatire)
variable sel_out : std_logic_vector(7 downto 0):="00000000";
begin 
	if mode='1' then--modul automat 
		
		case automat is 
			when "000"=> sel_out := "01001000";	
			when "001"=> sel_out := "01000010"; 
			when "010"=> sel_out := "01010101"; 
			when "011"=> sel_out := "01100101";
			when "100"=> sel_out := "01011011";
			when others => sel_out:="00000000";	 
end case; 
end if;
	
	if mode='0'  then --temp,viteza,prespalare,clatire  pentru modul manual
		sel_out:="00000000";
		
        case temperatura is 
            when "00" => sel_out(7 downto 6):="00"; -- 30 grade 
			             temp<=t30;
			when "01" => sel_out(7 downto 6):="01"; -- 40 grade
			            temp<=t40;
			when "10" => sel_out(7 downto 6):="10"; -- 60 grade
			            temp<=t60;
			when "11" => sel_out(7 downto 6):="11"; -- 90  grade 
			              temp<=t90;
			when others => sel_out (7 downto 6):="00"; --modificat de min
end case ;
		
		case turatii is
			when "00" => sel_out(5 downto 4):="00"; -- 800 rotatii 
			                 stur<=tur800;
			when "01" => sel_out(5 downto 4):="01"; -- 1000	rotatii
			                stur<=tur1000;
			when "10" => sel_out(5 downto 4):="10"; -- 1200	rotatii	
			              stur<=tur1200;
			when others => sel_out(5 downto 4):="00";
end case;
	
		case prespalare	is
			when '0' => sel_out(2):='0';-- fara prespalare 
			when '1' => sel_out(2):='1';-- cu prespalare
			when others => sel_out(2):='0';
end case;
	
		case clatire is 
			when'0' => sel_out(3):='0';	 -- fara clatire suplimentara   
			when'1' => sel_out(3):='1';	 -- cu clatire   suplimentara	  
			when others => sel_out(3):='0';
end case; 
		sel_out(0):='1';--se inchide usa
end if; 
	    ssel_out <=sel_out;
end process;
				 
		  spalare1: process (clk,usa_start)
begin 
        if usa_start='1' then 
            state <=st0;
        elsif clk'event and clk='1' then 
            state <=nextstate;
end if;
end process;


    spalare2: process (state)
begin 
        case state is
            when st0 =>
            if ssel_out(0)='0' then nextstate <=st0;
            elsif  ssel_out(2)='1' then nextstate<=pres;
            else nextstate <= sprin;
            end if;
            when pres =>
            nextstate <=sprin;
            when sprin => 
            if ssel_out(3)='1' then 
            nextstate <=cltsup;
            else nextstate <= clt;
end if ;

            when cltsup =>
            nextstate <=clt;
            when clt =>
            nextstate<=cent;
            when cent =>
            nextstate<=st0;
			
end case;
end process;
		
end arh1;
