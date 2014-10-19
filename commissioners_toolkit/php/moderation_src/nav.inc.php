    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <button type="button"class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="brand" href="/">w+k moderate.</a>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li <?if($me=="queue"){?>class="active"<?}?>>
                <a href="/index.php">Queue <span class="badge badge-info"><?=$all_totals['unmoderated']?></span></a>
              </li>
              <li class="divider-vertical"></li>
              <li <?if($me=="approved"){?>class="active"<?}?>>
                <a href="/approved-videos/">Approved Videos <span class="badge badge-info"><?=$all_totals['approved']?></span></a>
              </li>
              <li <?if($me=="rejected"){?>class="active"<?}?>>
                <a href="/rejected-videos/">Rejected Videos <span class="badge badge-info"><?=$all_totals['rejected']?></span></a>
              </li>
              <li <?if($me=="ignored"){?>class="active"<?}?>>
                <a href="/ignored-videos/">Ignored Videos <span class="badge badge-info"><?=$all_totals['ignored']?></span></a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>