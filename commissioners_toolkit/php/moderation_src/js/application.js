		$(document).ready(function(){
	
			
			$("a[rel^='reject']").live('click', function(){
				var vid_id;
				//if prettyphoto open, close it
				if($('#pp_buttons').hasClass('pp_social')){
					vid_id = $('.pp_description').text();
					$.prettyPhoto.close();
				} else {
					vid_id = $(this).attr('data-vid');
				}
				$('#reject_video_id').val(vid_id);
				$('#modal_reject').modal('show');
			});

			$("a[rel^='approve']").live('click', function(){
				var vid_id;
				//if prettyphoto open, close it
				if($('#pp_buttons').hasClass('pp_social')){
					vid_id = $('.pp_description').text();
					$.prettyPhoto.close();
				} else {
					vid_id = $(this).attr('data-vid');
				}
				$('#approve_video_id').val(vid_id);
				$('#modal_approve').modal('show');
			});

			$("a[rel^='ignore']").live('click', function(){
				var vid_id;
				//if prettyphoto open, close it
				if($('#pp_buttons').hasClass('pp_social')){
					vid_id = $('.pp_description').text();
					$.prettyPhoto.close();
				} else {
					vid_id = $(this).attr('data-vid');
				}
				$('#ignore_video_id').val(vid_id);
				$('#modal_ignore').modal('show');
			});

			$("a[rel^='do_reject']").live('click', function(){
				$('#modal_pleasewait').modal('show');
				$.ajax({
					type: 'GET',
					url: webservice_url + "moderation_reject.php?league_id=" + $('#reject_video_id').val() + " &callback=?",
					jsonpCallback: 'callbackReject',
					dataType: 'jsonp',
					success: function(data){
						$('#modal_pleasewait').modal('hide');
						if(data.status == "success"){
							window.location.reload();
						} else {
							$('#error_message').show();
						}
					}
					
				});
			});

			$("a[rel^='do_approve']").live('click', function(){
				$('#modal_pleasewait').modal('show');
				$.ajax({
					type: 'GET',
					url: webservice_url + "moderation_approve.php?league_id=" + $('#approve_video_id').val() + " &callback=?",
					jsonpCallback: 'callbackApprove',
					dataType: 'jsonp',
					success: function(data){
						$('#modal_pleasewait').modal('hide');
						if(data.status == "success"){
							window.location.reload();
						} else {
							$('#error_message').show();
						}
					}
					
				});
			});
						
			$("a[rel^='do_ignore']").live('click', function(){
				$('#modal_pleasewait').modal('show');
				$.ajax({
					type: 'GET',
					url: webservice_url + "moderation_ignore.php?league_id=" + $('#ignore_video_id').val() + " &callback=?",
					jsonpCallback: 'callbackIgnore',
					dataType: 'jsonp',
					success: function(data){
						$('#modal_pleasewait').modal('hide');
						if(data.status == "success"){
							window.location.reload();
						} else {
							$('#error_message').show();
						}
					}
					
				});
			});
						
			function callbackApprove(data){}
			function callbackIgnore(data){}
			function callbackReject(data){}
			
		});