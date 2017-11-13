local ip = ngx.var.remote_addr
local cclimit = ngx.shared.cclimit
local banlimit = ngx.shared.banlimit
local dislimit = ngx.shared.dislimit
local votelimit = ngx.shared.votelimit

local req = cclimit:get(ip)
local banreq = banlimit:get(ip)
local disreq = dislimit:get(ip)
local votereq = votelimit:get(ip)

local app = ngx.var.arg_app
local action = ngx.var.arg_action
local controller = ngx.var.arg_controller

if app == "system" and controller == "seccode" then
    if disreq then
	ngx.exit(503)
    else
	if req and req > 8 then
	    ngx.exit(400)
	end
	if banreq and banreq > 3 then
	    dislimit:set(ip,1,14400)
	    ngx.exit(503)
	else
	    if req then
		if req == 8 then
		    if banreq then
			banlimit:incr(ip,1)
		    else
			banlimit:set(ip,1,1800)
		    end
		    cclimit:incr(ip,1)
		    ngx.exit(400)
		else
		    cclimit:incr(ip,1)
		end
	    else
		cclimit:set(ip,1,10)
	    end
	end
    end
end

if app == "vote" and controller == "vote" and action == "ajaxvote" then
    if votereq then
	if votereq > 10 then
	    ngx.exit(400)
	else
	    votelimit:incr(ip,1)
	end
    else
	votelimit:set(ip,1,30)
    end
end

