<?php
// 自动生成JS跟踪代码
// Created by jjp 2017.11.18
// 
use Piwik\API\Request;
use Piwik\FrontController;

define('PIWIK_INCLUDE_PATH', realpath('./'));
define('PIWIK_USER_PATH', realpath('./'));
define('PIWIK_ENABLE_DISPATCH', false);
define('PIWIK_ENABLE_ERROR_HANDLER', false);
define('PIWIK_ENABLE_SESSION_START', false);

require_once PIWIK_INCLUDE_PATH . "/index.php";
require_once PIWIK_INCLUDE_PATH . "/core/API/Request.php";

function getJavascriptBySiteUrl($siteUrl) {
	$environment = new \Piwik\Application\Environment(null);
	$environment->init();

	FrontController::getInstance()->init();

	// 根据网址获取网站ID
	// This inits the API Request with the specified parameters
	// http://tongji.zzb.hj/?module=API&method=SitesManager.getSitesIdFromSiteUrl&url=http://www.zzb.hj/&format=xml&token_auth=anonymous
	$request1 = new Request('
				module=API
				&method=SitesManager.getSitesIdFromSiteUrl 
				&url=$siteUrl
				&format=json
				&token_auth=anonymous
	');
	// Calls the API and fetch XML data back
	$result1 = $request1->process();
	//echo $result1;

	// 根据网站ID，生成JS跟踪代码
	//https://demo.piwik.org/?module=API&method=SitesManager.getJavascriptTag&idSite=7&piwikUrl=&format=xml&token_auth=anonymous
	//
	$request2 = new Request('
				module=API
				&method=SitesManager.getJavascriptTag 
				&idSite=$require1
				&piwikUrl=
				&format=json
				&token_auth=anonymous
	');

	$result2 = $request2->process();
	return $result2;
}

$result = getJavascriptBySiteUrl("http://www.zzb.hj");

echo $result;

?>