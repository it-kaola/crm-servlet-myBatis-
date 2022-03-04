<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	/*
	上面这条语句得到的结果是：basePath=http://127.0.0.1:8080/crm/
	*/

	// 获取全局作用域中的阶段与可能性之间的map集合
	Map<String, String> pMap = (Map<String, String>) application.getAttribute("pMap");
	// 取得阶段与可能性之间的map集合中的所有键
	Set<String> set = pMap.keySet();

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

	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">

		$(function () {

			// 时间插件
			$(".topTime").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			// 时间插件
			$(".bottomTime").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			// 拼接json对象
			var json = {
				<%
					for(String key : set){
				%>
						"<%=key%>" : <%=pMap.get(key)%>,
				<%
					}
				%>
			};

			// 自动补全功能
			$("#create-customerName").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
							{ "name" : query },
							function (data) {
								// 这个data应该为 [{客户名称1}, {客户名称2}, .....]
								//alert(data);
								process(data);
							},
							"json"
					);
				},
				delay: 1500
			});

			// 为阶段的下拉框绑定change事件
			$("#create-stage").change(function () {
				// 获取阶段下拉列表的值
				var stage = $("#create-stage").val();

				// 根据阶段获取对应的可能性
				// 注意：这里的stage是动态生成的值，对于动态生成的值，用传统的 "json对象.key" 的形式是不能取到对应的value的
				// 对于动态生成的值，只能使用 "json对象[key]" 的形式取value
				var possibility = json[stage];

				// 将possibility放到对应的文本框中
				$("#create-possibility").val(possibility);

			})

			/*------------------------------------------------*/

			// 为查找市场活动源的"放大镜"图标绑定事件
			$("#openSearchActModal").click(function () {

				// 清空搜索框的记录
				$("#searchAct").val("");
				// 清空搜索到的记录
				$("#actListTBody").html("");
				// 打开查找市场活动的模态窗口
				$("#findMarketActivity").modal("show");


			});

			// 为市场活动搜索框绑定键盘敲击事件
			$("#searchAct").keydown(function (event) {
				if(event.keyCode == 13){

					$.ajax({
						url : "workbench/transaction/getActivityList.do",
						data : {"actName" : $.trim($("#searchAct").val())},
						type : "get",
						dataType : "json",
						success : function (respData) {
							// respData 应该为 [{市场活动1}, {市场活动2},.....]
							var html = "";
							$.each(respData, function (index, element) {
								html += '<tr>';
								html += '<td><input type="radio" name="normalRadio" value="'+ element.id +'"/></td>';
								html += '<td id="'+ element.id +'">'+ element.name +'</td>';
								html += '<td>'+ element.startDate +'</td>';
								html += '<td>'+ element.endDate +'</td>';
								html += '<td>'+ element.owner +'</td>';
								html += '</tr>';
							});
							// 为表格填充数据
							$("#actListTBody").html(html);
						}
					});

					return false; // 禁止模态窗口强制刷新
				}

			});

			// 为市场活动确定按钮绑定事件
			$("#actConfirmBtn").click(function () {
				var $checkedRadio = $("input[name=normalRadio]:checked");
				if($checkedRadio.length == 0){
					// 程序执行到此处说明用户没有选择市场活动但却点击了确定按钮，此时应该直接关闭模态窗口
					$("findMarketActivity").modal("hide");
				}else{
					// 将选中的市场活动名填写到文本框中
					var actId = $checkedRadio.val();
					var actName = $("#"+actId).html();
					$("#create-activitySrc").val(actName);
					// 将市场活动的id保存到隐藏域中，将来保存交易时，提交的是市场活动的id值
					$("#hidden-actId").val(actId);
				}
			});

			/*------------------------------------------------*/

			// 为查找联系人名称的"放大镜"图标绑定事件
			$("#openSearchContactsModal").click(function () {

				// 清空搜索框的记录
				$("#searchContacts").val("");
				// 清空搜索到的记录
				$("#contactsListTBody").html("");
				// 打开查找联系人名称的模态窗口
				$("#findContacts").modal("show");
			});

			// 为联系人搜索框绑定键盘敲击事件
			$("#searchContacts").keydown(function (event) {
				if(event.keyCode == 13){

					$.ajax({
						url : "workbench/transaction/getContactsList.do",
						data : {"fullname" : $.trim($("#searchContacts").val())},
						type : "get",
						dataType : "json",
						success : function (respData) {
							// respData 应该为 [{联系人1}, {联系人2},.....]
							var html = "";
							$.each(respData, function (index, element) {
								html += '<tr>';
								html += '<td><input type="radio" name="normalRadio" value="'+ element.id +'"/></td>';
								html += '<td id="'+ element.id +'">'+ element.fullname +'</td>';
								html += '<td>'+ element.email +'</td>';
								html += '<td>'+ element.mphone +'</td>';
								html += '</tr>';
							});
							// 为表格填充数据
							$("#contactsListTBody").html(html);
						}
					});

					return false; // 禁止模态窗口强制刷新
				}

			});

			// 为联系人确定按钮绑定事件
			$("#contactsConfirmBtn").click(function () {
				var $checkedRadio = $("input[name=normalRadio]:checked");
				if($checkedRadio.length == 0){
					// 程序执行到此处说明用户没有选择联系人但却点击了确定按钮，此时应该直接关闭模态窗口
					$("findContacts").modal("hide");
				}else{
					// 将选中的联系人名称填写到文本框中
					var contactsId = $checkedRadio.val();
					var fullname = $("#"+contactsId).html();
					$("#create-contactsName").val(fullname);
					// 将联系人的id保存到隐藏域中，将来保存交易时，提交的是联系人的id值
					$("#hidden-contacts").val(contactsId);
				}
			});

			/*------------------------------------------------*/

			// 为保存按钮绑定事件，执行保存交易信息并创建交易
			$("#saveBtn").click(function () {
				// 提交表单
				$("#tranFrom").submit();
			});




		});

	</script>

</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchAct" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="actListTBody">
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
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
						<button type="button" id="actConfirmBtn" class="btn btn-primary" data-dismiss="modal">确定</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="searchContacts" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsListTBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>
						</tbody>
					</table>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
						<button type="button" id="contactsConfirmBtn" class="btn btn-primary" data-dismiss="modal">确定</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" id="tranFrom" action="workbench/transaction/saveTransaction.do" method="post" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner" name="owner">
				  <c:forEach items="${userList}" var="userObj">
					  <option value="${userObj.id}" ${sessionScope.user.id eq userObj.id ? "selected" : ""}>${userObj.name}</option>
				  </c:forEach>
				  <%--<option>zhangsan</option>
				  <option>lisi</option>
				  <option>wangwu</option>--%>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName" name="tranName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control bottomTime" name="exceptedDate" id="create-expectedClosingDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-customerName" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-stage" name="stage">
			  	<option></option>
				  <c:forEach items="${stageList}" var="dicVal">
					  <option value="${dicVal.value}">${dicVal.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType" name="type">
				  <option></option>
				  <c:forEach items="${transactionTypeList}" var="dicVal">
					  <option value="${dicVal.value}">${dicVal.text}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" readonly id="create-possibility">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource" name="source">
				  <option></option>
					<c:forEach items="${sourceList}" var="dicVal">
						<option value="${dicVal.value}">${dicVal.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchActModal"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc">
				<input type="hidden" id="hidden-actId" name="activityId"/>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchContactsModal"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName">
				<input type="hidden" id="hidden-contacts" name="contactsId"/>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe" name="description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control topTime" id="create-nextContactTime" name="nextContactTime">
			</div>
		</div>
		
	</form>
</body>
</html>