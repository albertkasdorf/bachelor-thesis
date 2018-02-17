classdef cid < double
   enumeration
      time(1)
			p_sec(2)
			p_nsec(3)
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
			
			% Beacon Information: time;sec;nsec;id;range
			b_id(4)
			b_range(5)
			
			beacon_tag_address(4)
			beacon_anchor_address(5)
			beacon_range(6)
   end
end