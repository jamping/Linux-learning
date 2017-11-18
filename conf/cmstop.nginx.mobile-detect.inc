# redirect to mobile site
set $redirect_to_mobile '';
if ( $http_user_agent ~ ".*(iPhone|iPod|Android).*$" )
{
    set $redirect_to_mobile 'M';
}
if ( $query_string ~ "mobile&?" )
{
    set $redirect_to_mobile '';
}
if ( $redirect_to_mobile = 'M' )
{
    rewrite /$ http://m.cmstop.loc/ last;
    #rewrite ^(([^\.]*)/([0-9]+)\.shtml$) http://m.cmstop.loc/?m_redirect_url=$1 last;
    #rewrite (.+\/)([\d])(?:_?[\d]?)(\.shtml) http://m.cmstop.loc/?m_redirect_url=$1$2$3 last;
    rewrite ^(([^\.]*/)([0-9]+)(_[0-9]+)?(\.shtml)$) http://m.cmstop.loc/?m_redirect_url=$2$3$5 last;
}

# redirect to wap site
#set $redirect_to_wap "";
#if ( $http_x_wap_profile )
#{
#    rewrite /$ http://wap.cmstop.loc/ last;
#}
#if ( $http_via ~* wap )
#{
#    rewrite /$ http://wap.cmstop.loc/ last;
#}

#if ( $http_user_agent ~* (#opera\s*mini|opera\s*mobi|open\s*wave|windows\s*ce|nokia|sony|ericsson|mot|samsung|htc|sgh|lg|sharp|sie-|philips|panasonic|alcatel|lenovo|blackberry|meizu|netfront|symbian|ucweb|palm|nexusone|cldc|midp|wap|mmp) )
#{
#    rewrite /$ http://wap.cmstop.loc/ last;
#}
if ( $http_accept ~* ^(^text\/html)*vnd.wap.wml )
{
    rewrite /$ http://wap.cmstop.loc/ last;
}
