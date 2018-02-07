classdef cid < double
   enumeration
      time(1)
			x(4)
			y(5)
			
			bor_bid(4)			% beacon_id
			bor_pdf(5)			% pdf_type
			bor_meanx(6)
			bor_meany(7)
			bor_cov00(8)
			bor_cov01(9)
			bor_cov10(10)
			bor_cov11(11)
			
			bord_bid(4)
			bord_x(5)
			bord_y(6)
			bord_w(7)
			bord_cov00(8)
			bord_cov01(9)
			bord_cov10(10)
			bord_cov11(11)
   end
end