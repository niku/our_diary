require 'sinatra'

get '/' do
  %q{
<div class="wrapper">
	<header>
		<div class="logo">
			<img src="logo.jpg" width="250px" />
		</div>
	</header>
		<div class="box1">

<div id='slider' class='swipe'>
  <div class='swipe-wrap'>
    <div><image src="http://upload.wikimedia.org/wikipedia/commons/6/6b/Happy_child.jpg"></image></div>
    <div><image src="http://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Smooches_%28baby_and_child_kiss%29.jpg/640px-Smooches_%28baby_and_child_kiss%29.jpg"></image></div>
    <div><image src="http://farm3.staticflickr.com/2454/5782311333_7bb5b27197_z.jpg"></image></div>
  </div>
</div>

		</div>
</div><!-- .wrapper -->

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/swipe/2.0/swipe.min.js"></script>
<script>

// pure JS
var elem = document.getElementById('slider');
window.mySwipe = Swipe(elem, {
  // startSlide: 4,
  // auto: 3000,
  // continuous: true,
  // disableScroll: true,
  // stopPropagation: true,
  // callback: function(index, element) {},
  // transitionEnd: function(index, element) {}
});

// with jQuery
// window.mySwipe = $('#mySwipe').Swipe().data('Swipe');

</script>
}
end
