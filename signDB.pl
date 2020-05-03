#!/usr/bin/env perl

$main::engines = {
	SimpleTDS => [
		{
			url => '/header.php',
			file => 'data/SimpleTDS.txt',
			signs => [
				qr#<div class="subheader">v\d+\.\d+ Beta (MySQL version)</div>#i,
				qr#<div class="header">Simple TDS#i,
				qr#<title>Simple TDS</title>#i,
			],
		},
	],

	WordPress => [
		{
			url => '/wp-login.php',
			file => 'data/WordPress.txt',
			signs => [
				qr#/wp-login\.php\?action=lostpassword#i,
				qr#/wp-login\.php\?action=register#i,
				qr#type="password" name="pwd"#i,
				qr#type="submit" name="wp-submit"#i,
				qr#type="hidden" name="testcookie"#i,
			],
		},
		{
			url => '/robots.txt',
			file => 'data/WordPress.txt',
			signs => [
				qr#wp-#i,
				qr#/wp-.*/#i,
			],
		},
		{
			url => '',
			file => 'data/WordPress.txt',
			signs => [
				qr#wp-.+#i,
				qr#/wp-.+/#i,
			],
		},
	],

	Joomla => [
		{
			url => '/administrator/index.php',
			file => 'data/Joomla.txt',
			signs => [
				qr#input name="username"#i,
				qr#form action="index.php" method="post" name="login" id="form-login"#i,
				qr#input name="passwd"#i,
				qr#name="lang"#i,
				qr#type="submit".+?value="Login"#i,
				qr#input type="hidden" name="\w+" value="1"#i,
			],
		},
	],

	uCoz => [
		{
			url => '/robots.txt',
			file => 'data/uCoz.txt',
			signs => [
				qr#Disallow: /?ssid=#i,
				qr#Disallow: /abnl/#i,
			],
		},
	],

	Drupal => [
		{
			url => '/robots.txt',
			file => 'data/Drupal.txt',
			signs => [
				qr#Disallow: /CHANGELOG\.txt#i,
				qr#\# Paths \(clean URLs\)#i,
				qr#Disallow: /UPGRADE\.txt#i,
				qr#Disallow: /\?q=user/password/#i,
			],
		},
	],

	DataLifeEngine => [
		{
			url => '/admin.php',
			file => 'data/DataLifeEngine.txt',
			signs => [
				qr#<title>DataLife Engine#i,
				qr#name="login" action="" method="post"#i,
				qr#name="subaction" value="dologin"#i,
				qr#type="text" name="username"#i,
				qr#type="password" name="password"#i,
				qr#type="checkbox" name="login_not_save"#i,
			],
		},
		{
			url => '',
			file => 'data/DataLifeEngine.txt',
			signs => [
				qr#/templates/#i,
			],
		},
		{
			url => '/robots.txt',
			file => 'data/DataLifeEngine.txt',
			signs => [
				qr#/engine/#i,
				qr#\Wengine\W#i,
			],
		},
		{
			url => '/engine/ajax/updates.php',
			file => 'data/DataLifeEngine.txt',
			signs => [
				qr#\QИзвините, но в целях безопасности эта функция была отключена! Нет необходимости палить лишний раз нуленый движек ;-)\E#i,
			],
		},
	],
};