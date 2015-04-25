module ErrorsPagesHelper
	def throw_404
		render :file => "#{Rails.root}/public/404.html",  :status => 404
	end

	def throw_403
		render :file => "#{Rails.root}/public/403.html",  :status => 403
	end
end