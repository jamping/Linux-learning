----------------------------------------------------------
-- Nginx LUA Plugin For Application Detect SQL Injection
-- 
-- @copyright (c) CmsTop {@link http://www.cmstop.com}
-- @version 2013-12-24
----------------------------------------------------------

local SECURE = {};
SECURE.is_inject = function(input)
     local keywords = {'and', 'or', '&&', '||'};
     local keys = {};

     input = string.lower(input);
     input = string.gsub(input, '+', ' ');

     for key in pairs(keywords) do
          if string.find(input, keywords[key]) then
               keys[#keys+1] = keywords[key];
          end
     end

     if keys and (string.find(input, '%(')) then
          if string.find(input, '['..table.concat(keys,'|')..'][%W].*%(.*select[%W]') then
               return 0;
          end
     end

     if string.find(input, 'union') then
          if string.find(input, 'union[%W].*select[%W]') then
               return 1;
          end
     end

     if string.find(input, 'select') then
          if string.find(input, 'select[%W].*from') then
               return 2;
          end    
     end

     if string.find(input, 'into') and (string.find(input, 'outfile') or string.find(input, 'dumpfile')) then
          if string.find(input, 'into[%W].*[out|dump]file[%W]') then
               return 3;
          end
     end

    if string.find(input, 'database') then
        if string.find(input, 'database[%W].*and') then
            return 4;
        end
    end

     keys = {'database','user','sleep','load_file','benchmark'}
     for key,value in pairs(keys) do
          if (string.find(input, value)) then
               if (string.sub(input, 1, 6) == 'select') then
                    if string.find(input, '['..table.concat(keys, '|')..'][%W][%s|(/%*.-%*/))*?%(') then
                         return 5;
                    end
               end
          end    
     end

     return nil;
end

SECURE.is_useragent = function(input)
        local keys = {'libwww-perl', 'GetRight', 'GetWeb!', 'Go!Zilla', 'Go-Ahead-Got-It', 'WebBench', 'ApacheBench', 'Python-urllib', 'Havij', 'sqlmap', 'AhrefsBot', 'BackDoorBot', 'Java', 'http_load', 'must_revalidate', 'base64_decode', 'eval('};
        for key, value in pairs(keys) do
                if string.find(input, value) then
                        return true;
                end
        end
        return nil;
end

-- Detect
local request_method = ngx.req.get_method();
local request_uri = ngx.var.request_uri;
local user_agent = ngx.var.http_user_agent;

-- Detect The User-Agent
if SECURE.is_useragent(user_agent) then
    ngx.exit(400);
end

-- Detect The GET Variables
if request_uri then
    local get_args = ngx.req.get_uri_args();
    if next(get_args) ~= nil then
        if SECURE.is_inject(request_uri) ~= nil then
            ngx.exit(400);
        end
    end
end
