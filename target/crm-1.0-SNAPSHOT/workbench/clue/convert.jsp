<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	/*
	上面这条语句得到的结果是：basePath=http://127.0.0.1:8080/crm/
	*/
%>

<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<script type="text/javascript">
		$(function(){
			$("#isCreateTransaction").click(function(){
				if(this.checked){
					$("#create-transaction2").show(200);
				}else{
					$("#create-transaction2").hide(200);
				}
			});

			// 时间插件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			// 为"放大镜"图标绑定事件，打开搜索市场活动的模态窗口
			$("#openSearchActModal").click(function () {
				// 打开搜索市场活动的模态窗口
				$("#searchActivityModal").modal("show");
			});

			// 为搜索市场活动的模态窗口中的搜索框绑定事件，执行根据市场活动名搜索并展现相应的市场活动列表
			$("#actName").keydown(function (event) {
				if(event.keyCode == 13){

					$.ajax({
						url : "workbench/clue/getActListByName.do",
						data : {"actName" : $.trim($("#actName").val())},
						type : "get",
						dataType : "json",
						success : function (respData) {
							// respData 应该为 [{市场活动1}, {市场活动2}, .....]

							var html = "";

							$.each(respData, function (index, element) {
								html += '<tr>';
								html += '<td><input type="radio" name="nromalRadio" value="'+ element.id +'"/></td>';
								html += '<td id="'+ element.id +'">'+ element.name +'</td>';
								html += '<td>'+ element.startDate +'</td>';
								html += '<td>'+ element.endDate +'</td>';
								html += '<td>'+ element.owner +'</td>';
								html += '</tr>';
							});

							// 向表格中填充数据
							$("#actSearchTBody").html(html);

						}
					});

					// 禁止按下回车后，模态窗口强行刷新导致页面数据丢失
					return false;
				}
			});


			// 为提交按钮绑定事件，将市场活动的名字和市场活动的id存放到市场活动源文本框以及市场活动源文本框下面的隐藏域
			$("#submitActBtn").click(function () {
				// 获取市场活动的id
				var id = $("input[name=nromalRadio]:checked").val();
				// 获取市场活动的名字
				var name = $("#"+id).html();

				// 将以上两项信息分别存入市场活动源文本框以及市场活动源文本框下面的隐藏域
				$("#activityName").val(name);
				$("#activityId").val(id);

				// 关闭模态窗口
				$("#searchActivityModal").modal("hide");
			});


			// 为转换按钮绑定事件，执行线索转换的操作
			$("#convertBtn").click(function () {
				// 提交请求到后台，执行线索转换成客户的操作，这里不需要使用ajax请求了，直接使用传统请求即可
				// 请求结束后，最终响应回线索的列表页

				// 根据是否选中"为客户创建交易"的复选框，判断是否要为线索创建交易记录
				if($("#isCreateTransaction").prop("checked")){
					// 如果需要创建交易记录，除了要传递要转换的线索的id，还需要传递金额、交易名称、预计成交日期、阶段、市场活动的id
					// 如果是传统地址栏的请求
					// window.location.href = "workbench/clue/convertClue.do?clueId=xxx&money=xxx&name=xxx&expectedDate=xxx&stage=xxx&activityId=xxx"
					// 通过传统地址栏的请求非常麻烦，一旦表单扩充，地址栏上的参数可能会超出浏览器地址栏的上限
					// 可以使用form表单提交参数，只要是form表单内的元素有name属性都可以进行提交，并且可以以post方式提交数据

					// 提交表单
					$("#tranForm").submit();

				}else{
					// 如果不需要创建交易记录，传统请求的地址应该为：
					window.location.href = "workbench/clue/convertClue.do?clueId=${param.id}"
				}
			});

		});
	</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="actName" type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="actSearchTBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" id="submitActBtn" class="btn btn-primary" data-dismiss="modal">提交</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<!--在EL表达式中，如果直接写一个参数名，默认从域对象中取，取值顺序是pageContext，request，session，ServletContext 从小到大依次取值，直到取到值为止-->
		<!--如果想通过EL表达式获取浏览器地址栏上传来的参数，需要在参数前加上 param.参数名 -->
		<h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${param.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="tranForm" action="workbench/clue/convertClue.do" method="post">
		  <input type="hidden" name="clueId" value="${param.id}"/> <!--通过设置该隐藏域，在提交表单时把线索的id也提交上去-->
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<option></option>
		    	<c:forEach items="${stageList}" var="dicValue">
					<option value="${dicValue.value}">${dicValue.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activityName">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchActModal" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activityName" placeholder="点击上面搜索" readonly>
		    <input type="hidden" id="activityId" name="activityId"/>
		  </div>
		  <input type="hidden" name="flag" value="true"> <!--该标记位是为了让控制器知道请求是否需要添加交易记录，如果该参数不为空，表示需要创建交易记录-->
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" id="convertBtn" type="button" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>