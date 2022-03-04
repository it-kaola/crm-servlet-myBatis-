<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
/*
上面这条语句得到的结果是：basePath=http://localhost:8080/crm/
*/
%>


<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>


	<script type="text/javascript">

	$(function(){

		// 添加时间控件，在需要用到时间控件的元素加上class属性，其值为"time"
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});
		
		// 为创建按钮绑定事件，打开添加操作的模态窗口
		$("#createBtn").click(function () {

			// 连接数据库，获取所有用户的信息列表，为模态窗口中的所有者下拉框铺值
			// 局部刷新
			$.ajax({
				url:"workbench/activity/queryUserList.do",
				data:{},
				type:"get",
				dataType:"json",
				success:function (respData) {
					// respData数据的格式应为：[{"id":?,"name":?,"loginAct":?}, {用户2}, {用户3}.......]
					var html = "";
					// 遍历用户列表
					$.each(respData, function (index, element) {
						html += "<option value="+ element.id +">"+ element.name +"</option>";
					});
					// 为所有者下拉框铺值
					$("#create-marketActivityOwner").html(html);

					// 将当前登录用户，设置为所有者下拉框默认选项
					// 在jquery中，设置下拉框的默认选项这样写即可
						// $("#下拉框元素id值").val(默认要选中的option标签的value值)

					// 获取当前登录用户的id值
					var userId = "${sessionScope.user.id}"; // 在js中，使用EL表达式，必须将表达式用""括起来
					$("#create-marketActivityOwner").val(userId);

				}
			});

			// 所有者下拉框处理完毕后，展现模态窗口
			$("#createActivityModal").modal("show");
			// jquery中操作模态窗口的方式：
			// 1. 获得需要操作模态窗口的jquery对象
			// 2. 调用modal方法，为该方法传递参数，参数有两个："show":展示模态窗口；"hide":隐藏模态窗口
		});


		// 为保存按钮绑定事件
		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/activity/saveMarketActivity.do",
				data:{
					"owner":$.trim($("#create-marketActivityOwner").val()),
					"name":$.trim($("#create-marketActivityName").val()),
					"startDate":$.trim($("#create-startTime").val()),
					"endDate":$.trim($("#create-endTime").val()),
					"cost":$.trim($("#create-cost").val()),
					"description":$.trim($("#create-describe").val())
				},
				type:"post",
				dataType:"json",
				success:function (respData) {
					// respData应该为 {isSuccess:true/false}

					if(respData.isSuccess){
						// 展示保存过后的市场活动列表（使用局部刷新）
						/*
						* $("#activityPage").bs_pagination('getOption', 'currentPage') 该参数表示执行相关操作后停留在当前页
						* $("#activityPage").bs_pagination('getOption', 'rowsPerPage') 该参数表示执行相关操作后维持设置好的每页展现的记录数
						*
						* 这两个参数不需要我们进行任何修改，是由分页插件提供的
						* */
						// showActivitiesList(1, 2);
						// 执行完添加操作后，应让页面维持在第一页；并维持设置好的每页展现的记录数
						showActivitiesList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));


						// 清空添加操作的模态窗口中的数据
						// 对于form表单的jquery对象，提供了submit()方法
						// $("#addActivityForm").submit();
						// 注意：但是对于form表单的jquery对象，却没有相应的清空表单的方法
						// 要想清空表单，只能通过dom对象调reset()方法
						$("#addActivityForm")[0].reset(); // $("#addActivityForm")[0] 有jquery对象转成dom对象

						// 关闭模态窗口
						$("#createActivityModal").modal("hide");
					}else{
						alert("保存信息失败！")
					}
				}
			})
		});


		// 为查询按钮绑定事件
		$("#searchBtn").click(function () {

			// 只要点击了查询按钮，就把文本框中的值存到隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startTime").val($.trim($("#search-startTime").val()));
			$("#hidden-endTime").val($.trim($("#search-endTime").val()));

			showActivitiesList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));;
		});


		// 页面加载完毕后，触发分页的方法，默认每页展示2条数据，从第一页开始
		showActivitiesList(1, 2);


		// 为全选的复选框绑定事件
		$("#checkAllBox").click(function () {
			// prop()方法可以设置某个标签中的属性和属性值
			$("input[name=normalCheckBox]").prop("checked", this.checked); // this 表示当前的全选框对象 id=checkAllBox的jquery对象
		});

		// 为动态生成的复选框绑定事件
		// 以下这种做法是不行的
		/*$("input[name=normalCheckBox]").click(function () {
			alert(123);
		})*/

		//因为name=normalCheckBox的复选框标签是动态生成出来的，不可以使用$("选择器").事件名(function(){})的方式绑定事件
		// 动态生成的元素，要以on方法的形式来触发事件
		// 语法：$(需要绑定元素的有效外层元素(有效是指非动态生成的外层元素)).on(事件名, 需要绑定的jquery对象, 回调函数)
		$("#activityTbody").on("click", $("input[name=normalCheckBox]"), function () { // id=activityTbody的元素包含着动态生成的复选框标签
			$("#checkAllBox").prop("checked", $("input[name=normalCheckBox]").length === $("input[name=normalCheckBox]:checked").length)
		});


		// 为修改按钮绑定事件
		$("#editBtn").click(function () {
			var $checkedBox = $("input[name=normalCheckBox]:checked");

			if($checkedBox.length === 0){
				alert("请先选择一条需要修改的记录");
			}else if($checkedBox.length > 1){
				alert("请勿同时选择多条记录进行修改，每次只能修改一条记录");
			}else{
				// 程序能够执行到此处，说明用户只选中了一条记录进行修改
				var id = $checkedBox.val();
				// 根据id值发出ajax请求
				$.ajax({
					url : "workbench/activity/getUserListAndActivity.do",
					data : {"id" : id},
					type : "get",
					dataType : "json",
					success : function (respData) {
						// respData 应该为 {"userList":[{用户1}, {用户2}....], "clueObj":{"id":xxx, "name" : xxx, ......}}

						// 为所有者下拉框铺值
						var html = "";
						$.each(respData.userList, function (index, element) {
							html += "<option value='"+ element.id +"'>"+ element.name +"</option>"
						});

						$("#edit-marketActivityOwner").html(html);

						// 为模态窗口中的文本框填充数据
						$("#edit-id").val(respData.clueObj.id); // 想隐藏域中存放这条记录的id值，方便接下来的更新操作
						$("#edit-marketActivityOwner").val(respData.clueObj.owner);
						$("#edit-marketActivityName").val(respData.clueObj.name);
						$("#edit-startTime").val(respData.clueObj.startDate);
						$("#edit-endTime").val(respData.clueObj.endDate);
						$("#edit-cost").val(respData.clueObj.cost);
						$("#edit-describe").val(respData.clueObj.description);

						// 展示模态窗口
						$("#editActivityModal").modal("show");
					}
				})
			}
		});


		// 为更新按钮绑定事件，执行市场活动信息的修改操作
		// 在以后的实际项目开发中，一定是先做添加操作，再做修改操作这种顺序
		// 添加操作的代码可以直接copy到更新操作中，然后进行修改，这样可以节省开发时间
		$("#updateBtn").click(function () {
			$.ajax({
				url:"workbench/activity/updateMarketActivity.do",
				data:{
					"id":$("#edit-id").val(),
					"owner":$.trim($("#edit-marketActivityOwner").val()),
					"name":$.trim($("#edit-marketActivityName").val()),
					"startDate":$.trim($("#edit-startTime").val()),
					"endDate":$.trim($("#edit-endTime").val()),
					"cost":$.trim($("#edit-cost").val()),
					"description":$.trim($("#edit-describe").val())
				},
				type:"post",
				dataType:"json",
				success:function (respData) {
					// respData应该为 {isSuccess:true/false}

					if(respData.isSuccess){
						// 展示修改过后的市场活动列表（使用局部刷新）
						// showActivitiesList(1, 2);

						// 执行完更新操作后，应该停留在当前页，并维持设置好的每页展现的记录数
						showActivitiesList($("#activityPage").bs_pagination('getOption', 'currentPage'), $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						// 关闭模态窗口
						$("#editActivityModal").modal("hide");
					}else{
						alert("修改信息失败！")
					}
				}
			})
		});


		// 未删除按钮绑定事件，执行市场活动的删除操作
		$("#deleteBtn").click(function () {

			// 定位到所有被选中的复选框的jquery对象
			var $checkedBox = $("input[name=normalCheckBox]:checked");

			if($checkedBox.length === 0){
				alert("请先选择需要删除的市场活动记录");
			}else{
				if(confirm("是否确认删除选中的市场活动记录？")){
					// url : workbench/activity/deleteMarketActivities.do?id=值1&id=值2&id=值3....
					// 之前的ajax请求都是用json格式来传递参数，但是在删除操作中，可能删除多条记录，id的只有多个，所以只能用传统的方式传参

					// 先拼接参数
					var parameter = "";
					// 遍历所有被选中的复选框的jquery对象
					$.each($checkedBox, function (index, element) {
						parameter += ("id=" + element.value);
						if(index < $checkedBox.length-1){
							// 程序能执行到此处说明这个dom对象不是最后一个
							parameter += "&";
						}
					});

					$.ajax({
						url : "workbench/activity/deleteMarketActivity.do",
						data : parameter,
						type : "post",
						dataType : "json",
						success : function (respData) {
							// respData应该为 {"isSuccess":true/false}
							if(respData.isSuccess){
								// 程序执行到此处说明删除成功，此时需要刷新市场活动列表
								// showActivitiesList(1, 2);
								// 执行完删除操作后，应让页面维持在第一页；并维持设置好的每页展现的记录数
								showActivitiesList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
							}else{
								alert("删除市场活动信息失败");
							}
						}
					})
				}
			}

		})


	});


	// 展示市场活动列表
	/*
	* 对于所有关系型数据库，做前端分页相关操作的基础组件就是 pageNo 和 pageSize
	* pageNo：页码
	* pageSize：每页展示的记录数
	*
	* showActivitiesList方法，通过发出ajax请求到后台，从后台取得最新的市场活动信息列表，通过相应回来的数据，局部刷新列表页面
	* 什么情况下，需要调用showActivitiesList方法？（什么情况下需要刷新市场活动列表）
	* 	（1）点击左侧菜单中的"市场活动"超链接，需要刷新列表
	* 	（2）添加、修改、删除后，需要刷新市场活动列表
	* 	（3）点击"查询"按钮时，需要刷新市场活动列表
	* 	（4）点击分页组件的时候，需要刷新市场活动列表
	*
	* 	以上6个入口都需要调用该方法
	* */
	function showActivitiesList(pageNo, pageSize) {

		// 将隐藏域中的内容重新填入对应的文本框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startTime").val($.trim($("#hidden-startTime").val()));
		$("#search-endTime").val($.trim($("#hidden-endTime").val()));

		// 每次刷新市场活动列表时，取消选中全选的复选框
		$("#checkAllBox").prop("checked", false);

		$.ajax({
			url:"workbench/activity/queryMarketActivities.do",
			data:{
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"name" : $.trim($("#search-name").val()),
				"owner" : $.trim($("#search-owner").val()),
				"startDate" : $.trim($("#search-startTime").val()),
				"endDate" : $.trim($("#search-endTime").val())
			},
			type:"get",
			dataType:"json",
			success:function (respData) {
				// respData
					// 我们需要的是，市场活动信息列表 [{"id":?, "owner":?,....}, {市场活动2}, {市场活动3}.....]
					// 但是分页组件还需要，查询出来的总记录条数 {"total":总记录条数}
				// 将以上两组信息合并，最后响应体中传输的应该是
				// {"total" : 总记录条数, "dataList" : [{"id":?, "owner":?,....}, {市场活动2}, {市场活动3}.....]}
				var html = "";

				$.each(respData.dataList, function (index, element) {
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="normalCheckBox" value="'+ element.id +'"/></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/showActDetail.do?id='+ element.id +'\';">'+ element.name +'</a></td>';
					html += '<td>'+ element.owner +'</td>';
					html += '<td>'+ element.startDate +'</td>';
					html += '<td>'+ element.endDate +'</td>';
					html += '</tr>';
				});

				$("#activityTbody").html(html);

				// 计算总页数
				var totalPages = respData.total%pageSize == 0 ? respData.total/pageSize : (parseInt(respData.total/pageSize))+1;

				// 数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#activityPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: respData.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					// 该回调函数是在点击分页组件的时候触发的
					onChangePage : function(event, data){ // 这两个参数是分页插件提供的，不要擅自修改
						showActivitiesList(data.currentPage , data.rowsPerPage);
					}
				});

			}
		})
	}

	</script>
</head>
<body>

	<!--隐藏域-->
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startTime">
	<input type="hidden" id="hidden-endTime">

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">

					<form id="addActivityForm" class="form-horizontal" role="form">

						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime">
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<!--data-dismiss="modal" 表示关闭模态窗口-->
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveBtn" class="btn btn-primary">保存</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id" />

						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<!--
									关于文本域textarea标签：
										1. 一定要以标签对的形式呈现，即<textarea></textarea>要成对出现，标签内无内容时，标签对要紧紧挨着，不能存在任何空白符
										2. textarea标签没有value属性，但是在标签中插入内容使用的是jquery对象.val()方法，而不是使用jquery对象.html()
								-->
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="updateBtn" class="btn btn-primary">更新</button>
				</div>
			</div>
		</div>
	</div>




	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">

			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startTime" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endTime">
				    </div>
				  </div>

				  <!--form表单中的button标签的type值默认为"submit"，必须手动设置为"button"！！！！！！！！-->
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button> <!--如果type的属性值为"submit"，当点击该按钮后，执行的是一次全局刷新-->
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <!--
				  	注意：data-toggle属性和data-target属性
				  	当点击该按钮时
				  		data-toggle="modal" 表示即将要打开一个模态窗口
				  		data-target="#createActivityModal" 表示要打开哪个模态窗口，通过#id的形式找到该窗口

				  	现在是以属性和属性值的方式写在button元素中，以此来打开一个模态窗口
				  	这样做的缺点是：没有办法对该按钮进行其他功能的扩充，例如在点击按钮后先弹出一个alert窗口，再打开模态窗口，这样的需求是无法实现的

				  	所以在实际的项目开发中，对于触发模态窗口的操作，一定不要写死在元素中
				  	应该有我们自己通过编写js代码来实现自己想要的功能

				  -->
				  <button type="button" id="createBtn" class="btn btn-primary"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" id="editBtn" class="btn btn-default"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" id="deleteBtn" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAllBox"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityTbody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>