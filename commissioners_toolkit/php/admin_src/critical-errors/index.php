<?

include "../../includes.inc.php";

$me = "criticalerrors";

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
	<title>w+k ffl admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
	
	<link href="/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/css/prettyPhoto.css" rel="stylesheet" />
	<link href="/css/application.css" rel="stylesheet" />

</head>

  <body>

	<? include "../nav.inc.php"; ?>

	<!-- container -->
	<div class="container-fluid">

		<!-- intro -->
		<div class="row-fluid">
	        <div class="jumbotron subhead">
				<h1>Disaster Recovery Plan</h1>
				<p class="lead">How to recover from catastrophic system malfunctions.</p>
				<hr/>
			</div>				
		</div>
		<!-- /intro -->
		
		<div class="alert alert-info">You'll probably need some credentials. Contact Husani / Brandon K. / Hana for access to the project's master password document.</div>
	
		<div style="margin-bottom:15px">
			<h3>Too much traffic - need more webservers</h3>
			<ol>
				<li>
					<p>
						Login to <a href="" target="_blank">Rackspace Cloud Management</a> and create a new cloud server with the following attributes:
						<ul>
							<li><b>Name:</b> espn-ffl-prodX, where X is the number of existing webservers plus one.</li>
							<li><b>OS:</b> Ubuntu 10.x</li>
							<li><b>Memory:</b> 8GB</li>
						</ul>
					</p>
				</li>
				<li>
					<p>
						Once you receive notification that the server is online (should take less than 5 minutes), login to the server via SSH and run the following commands, <i>in order</i>:
						<ul>
							<li>apt-get update</li>
							<li>apt-get install apache2</li>
							<li>apt-get install php5-mysql</li>
							<li>apt-get install curl</li>
							<li>apt-get install php5-curl</li>
							<li>apt-get install mysql-client</li>
							<li>service httpd restart</li>
						</ul>
					</p>
				</li>
				<li>
					<p>
						Add a VirtualHost to apache, as follows:
						<pre>
&lt;VirtualHost *:80&gt;
  ServerAdmin admin@sportsr.us
  ServerName ffl.sportsr.us

  DirectoryIndex index.php index.html
  DocumentRoot /var/www/vhosts/ffl.sportsr.us/src/

  ErrorLog /var/www/vhosts/ffl.sportsr.us/logs/error_log
  CustomLog /var/www/vhosts/ffl.sportsr.us/logs/access_log combined

  &lt;Directory /var/www/vhosts/ffl.sportsr.us/src&gt;
    Options -Indexes
  &lt;/Directory&gt;

  &lt;Directory ~ &quot;\.svn&quot;&gt;
    Order allow,deny
    Deny from all
  &lt;/Directory&gt;

&lt;/VirtualHost&gt;
						</pre>
					</p>
				</li>
				<li>
					<p>Login to Beanstalk, open the "ESPN Fantasy Football Site 2012" repository, and navigate to the Deployments section. Click "Production" and then click "Servers". Click "Add a server", and copy an existing server setup.</p>
				</li>
				<li>
					<p>Once the server has been added, trigger a manual deployment.</p>
				</li>
				<li>
					<p>Once the deployment is complete, log into Rackspace Cloud Management. Click "Hosting", "Load Balancers", and then "espn-ffl-lb". Add the new server to the list.</p>
				</li>
				<li>
					<p>The new server is now setup and accepting requests. Repeat this process for each server you need to add.</p>
				</li>
			</ol>
		</div>
	
		<div style="margin-bottom:15px">
			<h3>Too much traffic - need more database resources</h3>
			<p>Available database resources should automatically scale based on traffic. If this does not happen, login to Xeround and manually add resources.</p>
		</div>
	
		<div style="margin-bottom:15px">
			<h3>An existing webserver is offline</h3>
			<p>Restart it. Or kill it and create a new one using the instructions above. The load balancer will automatically stop sending requests to servers that are no longer online.</p>
		</div>
						

	</div>
	<!-- /container -->
	
	<? include "../jsincludes.inc.php"; ?>
	

</body>
</html>