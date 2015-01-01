<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ include file="../layout/taglib.jsp"%>

<c:choose>
	<c:when test="${blogDetail eq true}">
		<table style="width:100%">
			<tr>
				<td style="width:50px">
					<a href="${blog.homepageUrl}" target="_blank">
						<img src="<spring:url value='/resources/images/home.png' />" alt="home" style="width:20px;padding-top:7px;" />
					</a>
					<a href="${blog.url}" target="_blank">
						<img src="<spring:url value='/resources/images/rss.png' />" alt="rss" style="width:20px;padding-top:7px;" />
					</a>
				</td>
				<td>
					<h1 style="font-size:25px">${title}</h1>
				</td>
			</tr>
		</table>
	</c:when>
	<c:otherwise>
		<h1 style="font-size:25px">${title}</h1>
	</c:otherwise>
</c:choose>

<jsp:include page="../layout/adsense.jsp" />

<br />

<table class="table table-bordered table-hover table-striped">
	<tbody>
		<tr>
			<td>
				<c:choose>
					<c:when test="${blogDetail eq true}">
					</c:when>
					<c:otherwise>
						<span class="badge">${blogCount} blogs</span>
					</c:otherwise>
				</c:choose>
				<span class="badge">last update was ${lastIndexDate} minutes ago</span>
				<security:authorize access="hasRole('ROLE_ADMIN')">
					<span class="badge">items: ${itemCount}</span>
					<span class="badge">users: ${userCount}</span>
				</security:authorize>
			</td> 
		</tr>
		<c:forEach items="${items}" var="item">
			<tr>
				<c:choose>
					<c:when test="${item.enabled}">
						<c:set var="customCss" value="" />
					</c:when>
					<c:otherwise>
						<c:set var="customCss" value="text-decoration: line-through;color:grey" />
					</c:otherwise>
				</c:choose>
				<td>
				
					
<!-- 					<table style="float:left;margin-right:5px"> -->
<!-- 						<tr> -->
<!-- 							<td style="padding:2px"> -->
<!-- 								TODO ziskat cookie a pokud existuje, pak nepovolit klik (a zobrazit ikonu, ze uz bylo kliknuto) -->
<%-- 								cookie: ${cookie['5'].value} --%>
								
<%-- 								<img src="<spring:url value='/resources/images/like.png' />" id="${item.id}" onClick="itemLike(event)" style="cursor:pointer" /> --%>
<!-- 							</td> -->
					
<!-- 							<td style="padding:2px"> -->
<%-- 								<span class="likeCount_${item.id}">${item.likeCount}</span> --%>
<!-- 							</td> -->
<!-- 						</tr> -->
<!-- 						<tr> -->
<!-- 							<td style="padding:2px"> -->
<%-- 								<img src="<spring:url value='/resources/images/dislike.png' />" onClick="itemDislike(event)" id="${item.id}" style="cursor:pointer" /> --%>
<!-- 							</td> -->
<!-- 							<td style="padding:2px"> -->
<%-- 								<span class="dislikeCount_${item.id}">${item.dislikeCount}</span> --%>
<!-- 							</td> -->
<!-- 						</tr> -->
<!-- 					</table> -->
				

						<a id="${item.id}" href="<c:out value="${item.link}" />" target="_blank" style="${customCss}" class="itemLink" onClick="itemClick(event)">
							<img id="${item.id}" src="<spring:url value='/spring/icon/${item.blog.id}' />" alt="icon" style="float:left;padding-right:5px" />
							<strong id="${item.id}">
									${item.title} <span class="glyphicon glyphicon-share-alt"></span>
							</strong>
						</a>
					<br />
					<span style="${customCss}" class="itemDesc">${item.description}</span>
					<br /><br />
					<fmt:formatDate value="${item.publishedDate}" pattern="dd-MM-yyyy hh:mm:ss" />:
					<strong>
						<a href="<spring:url value='/blog/${item.blog.shortName}.html' />"><c:out value="${item.blog.name}" /></a>
					</strong>
					<security:authorize access="hasRole('ROLE_ADMIN')">
						<a href="<spring:url value="/items/toggle-enabled/${item.id}.html" />" class="btn btn-primary btn-xs btnToggleEnabled">
							<c:choose>
								<c:when test="${item.enabled}">
									disable
								</c:when>
								<c:otherwise>
									enable
								</c:otherwise>
							</c:choose>
						</a>
						<span class="badge">views: ${item.clickCount}</span>
					</security:authorize>
				</td>
			</tr>
		</c:forEach>
		<tr class="loadNextRow">
			<td class="loadNextColumn">
				<div style="text-align: center">
					<c:choose>
						<c:when test="${blogDetail eq true}">
							<strong><a href="<spring:url value='' />?page=${nextPage}&shortName=${blogShortName}" class="loadButton">load next 10 items</a></strong>
						</c:when>
						<c:otherwise>
							<!-- TODO funguje strankovani pri vypnutem javascriptu i u top stranek? ASI NEFUNGUJE!!! -->
							<strong><a href="<spring:url value='' />?page=${nextPage}" class="loadButton">load next 10 items</a></strong>
						</c:otherwise>
					</c:choose>
				</div>
			</td>
		</tr>
	</tbody>
</table>

<c:choose>
	<c:when test="${topViews eq true}">
		<script>
			var topViews = true;
		</script>
	</c:when>
	<c:otherwise>
		<script>
			var topViews = false;
		</script>
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${max eq true}">
		<script>
			var max = true;
			var maxValue = "${maxValue}";
		</script>
	</c:when>
	<c:otherwise>
		<script>
			var max = false;
		</script>
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${blogDetail eq true}">
		<script>
			var blogDetail = true;
			var blogShortName = "${blogShortName}";
		</script>
	</c:when>
	<c:otherwise>
		<script>
			var blogDetail = false;
		</script>
	</c:otherwise>
</c:choose>


<script>

	$(document).ready(function() {

		var currentPage = 0;
		$(".loadButton").click(function(e) {
			e.preventDefault();
			var nextPage = currentPage + 1;
			var url = "<spring:url value='/page/' />" + nextPage + ".json";
			var iconBaseUrl = "<spring:url value='/spring/icon/' />";
			var blogDetailBaseUrl = "<spring:url value='/blog/' />";
			if(topViews == true) {
				url = url + "?topviews=true";
				if(max == true) {
					url = url + "&max=" + maxValue;
				}
				if(blogDetail == true) {
					url = url + "&shortName=" + blogShortName;
				}
			} else if(blogDetail == true) {
				url = url + "?shortName=" + blogShortName;
			}


			$.getJSON( url, function( data ) {
				var html = "";
				$.each(data, function(key, value) {
					html += "<tr><td>";

// 					html += '<a href="" onClick="itemLike(event)" id="' + value.id + '">like</a> ';
// 					html += '<span class="likeCount_' + value.id + '">' + value.likeCount + '</span> ';
// 					html += '<a href="" onClick="itemDislike(event)" id="' + value.id + '">dislike</a> ';
// 					html += '<span class="dislikeCount_' + value.id + '">' + value.dislikeCount + '</span> ';

					var css = "";
					if(value.enabled == false) {
						css = "text-decoration: line-through;color:grey";
					}
					html += "<a href='" + value.link + "' target='_blank' class='itemLink' style='" + css + "' onClick='itemClick(event)' id='" + value.id + "'>";
					html += "<img src='" + iconBaseUrl + value.blog.id + "' alt='icon' style='float:left;padding-right:10px' id='" + value.id + "' />";
					html += "<strong id='" + value.id + "'>";
					html += value.title;
					html += " <span class='glyphicon glyphicon-share-alt'></span>";
					html += "</strong>";
					html += "</a>";
					html += "<br />";
					html += "<span class='itemDesc' style='" + css + "'>";
					html += value.description;
					html += "</span>";
					html += "<br />";
					html += "<br />";
					var date = new Date(value.publishedDate);
					html += ("0" + date.getDate()).slice(-2) + "-" + ("0" + (date.getMonth() + 1)).slice(-2) + "-" + date.getFullYear();
					html += " " + ("0" + date.getHours()).slice(-2) + ":" + ("0" + date.getMinutes()).slice(-2) + ":" + ("0" + date.getSeconds()).slice(-2);
					html += ": ";
					html += "<strong>";
					html += "<a href='" + blogDetailBaseUrl + value.blog.shortName + ".html'>";
					html += value.blog.name;
					html += "</a>";
					html += "</strong>";
 					html += adminMenu(value);
					html += "</td></tr>";
				});
				var newCode = $(".table tr:last").prev().after(html);
				adminHandler(newCode);
			});
			currentPage++;
		});
		
	});
	
	function itemClick(e) {
		var itemId = $(e.target).attr("id");
		$.post(
				"<spring:url value='/inc-count.html' />", 
				{ itemId: itemId },
				function(data, status) {
				}
		);
	}
	
	function itemLike(e) {
		e.preventDefault();
		var itemId = $(e.target).attr("id");
		$.post(
				"<spring:url value='/social/like.html' />", 
				{ itemId: itemId },
				function(data, status) {
					$(".likeCount_" + itemId).text(data);
					// http://stackoverflow.com/questions/1458724/how-to-set-unset-cookie-with-jquery
// 					$.cookie(itemId, "1");
				}
		);
	}

	function itemDislike(e) {
		e.preventDefault();
		var itemId = $(e.target).attr("id");
		$.post(
				"<spring:url value='/social/dislike.html' />", 
				{ itemId: itemId },
				function(data, status) {
					$(".dislikeCount_" + itemId).text(data);
				}
		);
	}

</script>

<security:authorize access="hasRole('ROLE_ADMIN')" var="isAdmin" />

<c:choose>
	<c:when test="${isAdmin eq true}">
		<script type="text/javascript">
		
			$(document).ready(function() {
				$(".btnToggleEnabled").click(toggleEnabledItem);
			});
		
			// generate menu for administrator
			function adminMenu(item) {
				var html = " ";
				html += '<a href="<spring:url value="/" />items/toggle-enabled/' + item.id + '.html" class="btn btn-primary btn-xs btnToggleEnabled">';
				if(item.enabled) {
					html += 'disable';
				} else {
					html += 'enable';
				}
				html += '</a>';
				html += ' <span class="badge">views: ' + item.clickCount + '</span>';
				return html;
			}

			var toggleEnabledItem = function (e) {
				e.preventDefault();
				var href = $(this).attr("href");
				var curr = $(this);
				$.getJSON( href, function(data) {
					var css1 = "";
					var css2 = "";
					if(data == true) {
						css1 = "";
						css2 = "";
						$(curr).text("disable");
					} else {
						css1 = "line-through";
						css2 = "grey";
						$(curr).text("enable");
					}
					var itemLink = $(curr).closest("tr").find(".itemLink");
					itemLink.css("text-decoration", css1);
					itemLink.css("color", css2);
					var itemDesc = $(curr).closest("tr").find(".itemDesc");
					itemDesc.css("text-decoration", css1);
					itemDesc.css("color", css2);
				});
			};

			function adminHandler(newCode) {
				$(".btnToggleEnabled").on("click", toggleEnabledItem);
			}

		</script>
	</c:when>
	<c:otherwise>
		<script type="text/javascript">
			function adminMenu(item) {
				return "";
			}
			function adminHandler(newCode) {
			}
		</script>
	</c:otherwise>
</c:choose>

<jsp:include page="../layout/adsense.jsp" />
