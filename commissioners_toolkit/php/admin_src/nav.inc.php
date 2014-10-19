    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <button type="button"class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="brand" href="/">w+k ffl admin.</a>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li <?if($me=="stats"){?>class="active"<?}?>>
                <a href="/index.php">Stats</a>
              </li>
              <li <?if($me=="ohshit"){?>class="active"<?}?>>
                <a href="/oh-shit/">Disaster Recovery Plan</a>
              </li>
            </ul>
            <!--<ul class="nav pull-right">
            	<li class="divider-vertical"></li>
            	<li class="dropdown">
              		<a href=""><span class="status_lb badge badge-success">lb</span></a>
         	    </li>
            	<li class="dropdown">
              		<a href=""><span class="status_prod1 badge badge-success">prod1</span></a>
         	    </li>
            	<li class="dropdown">
              		<a href=""><span class="status_prod2 badge badge-success">prod2</span></a>
         	    </li>
            	<li class="dropdown">
              		<a href=""><span class="status_prod3 badge badge-success">prod3</span></a>
         	    </li>
            	<li class="dropdown">
              		<a href=""><span class="status_db badge badge-success">db</span></a>
         	    </li>
         	</ul>-->
          </div>
        </div>
      </div>
    </div>