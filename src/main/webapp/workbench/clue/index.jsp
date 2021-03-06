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

			// 时间插件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			// 为全选的复选框绑定事件
			$("#checkAllBox").click(function () {
				$("input[name=normalCheckBox]").prop("checked", this.checked)
			});

			// 为动态生成的复选框绑定事件
			$("#clueTbody").on("click", $("input[name=normalCheckBox]"), function () {
				$("#checkAllBox").prop("checked", $("input[name=normalCheckBox]").length == $("input[name=normalCheckBox]:checked").length)
			});

			// 为创建按钮绑定事件
			$("#createBtn").click(function () {

				$.ajax({
					url : "workbench/clue/queryUserList.do",
					data : {},
					type : "get",
					dataType : "json",
					success : function (respData) {
						// respData 应该为 [{用户1}, {用户2}, ....]
						var html = "";
						$.each(respData, function (index, element) {
							html += "<option value='"+ element.id +"'>"+ element.name +"</option>"
						});

						// 向下拉框中填充元素
						$("#create-owner").html(html);

						// 将所有者下拉框的值设置为当前登录用户
						var userId = "${sessionScope.user.id}";
						$("#create-owner").val(userId);
					}
				});

				// 打开相应的模态窗口
				$("#createClueModal").modal("show");
			});

			// 为保存按钮绑定事件，执行添加线索操作
			$("#saveBtn").click(function () {
				$.ajax({
					url : "workbench/clue/saveClue.do",
					data : {
						"owner" : $.trim($("#create-owner").val()),
						"company" : $.trim($("#create-company").val()),
						"appellation" : $.trim($("#create-appellation").val()),
						"fullname" : $.trim($("#create-fullname").val()),
						"job" : $.trim($("#create-job").val()),
						"email" : $.trim($("#create-email").val()),
						"phone" : $.trim($("#create-phone").val()),
						"website" : $.trim($("#create-website").val()),
						"mphone" : $.trim($("#create-mphone").val()),
						"source" : $.trim($("#create-source").val()),
						"state" : $.trim($("#create-state").val()),
						"description" : $.trim($("#create-description").val()),
						"contactSummary" : $.trim($("#create-contactSummary").val()),
						"nextContactTime" : $.trim($("#create-nextContactTime").val()),
						"address" : $.trim($("#create-address").val())
					},
					type : "post",
					dataType : "json",
					success : function (respData) {
						// respData 应该为 {isSuccess : true/false}
						if(respData.isSuccess){

							// 刷新列表
							showClueList(1, 2);

							// 清空表单
							$("#createClueForm")[0].reset();

							// 关闭模态窗口
							$("#createClueModal").modal("hide");
						}else{
							alert("保存线索失败");
						}
					}
				})
			});

			// 为查询按钮绑定事件，执行线索的查询操作
			$("#searchBtn").click(function () {
				// 点击查询按钮后，将查询的条件先存放到隐藏域中
				$("#hidden-fullname").val($.trim($("#search-fullname").val()));
				$("#hidden-company").val($.trim($("#search-company").val()));
				$("#hidden-phone").val($.trim($("#search-phone").val()));
				$("#hidden-source").val($.trim($("#search-source").val()));
				$("#hidden-owner").val($.trim($("#search-owner").val()));
				$("#hidden-mphone").val($.trim($("#search-mphone").val()));
				$("#hidden-state").val($.trim($("#search-state").val()));

				// 展示线索列表
				showClueList(1, 2);
			});

			// 为删除按钮绑定事件，执行批量删除线索的操作
			$("#deleteBtn").click(function () {

				var $checkedBox = $("input[name=normalCheckBox]:checked");

				if($checkedBox.length == 0){
					alert("请选择至少一条想要删除的线索");
				}else{
					if(confirm("确定删除这些线索吗？")){
						var param = "";
						$.each($checkedBox, function (index, element) {
							param += ("id=" + element.value);
							if(index < $checkedBox.length-1){
								param += "&";
							}
						});

						$.ajax({
							url : "workbench/clue/deleteClue.do",
							data : param,
							type : "post",
							dataType : "json",
							success : function (respData) {
								// respData 应该为 {"isSuccess" : true/false}
								if(respData.isSuccess){
									// 刷新线索列表
									showClueList(1, 2);
								}else{
									alert("删除线索失败");
								}
							}
						})
					}
				}
			});

			// 为修改按钮绑定事件，执行修改线索信息的操作
			$("#editBtn").click(function () {

				var $checkBox = $("input[name=normalCheckBox]:checked");

				if($checkBox.length == 0){
					alert("请选择一条您要修改的线索");
				}else if($checkBox.length > 1){
					alert("请勿同时选择多条线索进行修改，每次只能修改一条线索");
				}else{
					var clueId = $checkBox.val();

					$.ajax({
						url : "workbench/clue/getUserListAndClue.do",
						data : {"clueId" : clueId},
						type : "get",
						dataType : "json",
						success : function (respData) {
							// respData 应该为 {"userList" : [{用户1}, {用户2}....], "clueObj" : {"id" : xxx, .....}}
							var html = "";
							$.each(respData.userList, function (index, element) {
								html += "<option value='"+ element.id +"'>"+ element.name +"</option>"
							});

							// 为所有者下拉框填充数据
							$("#edit-owner").html(html);

							// 为修改线索的模态窗口中的其他文本框填充值
							$("#edit-owner").val(respData.clueObj.owner);
							$("#edit-company").val(respData.clueObj.company);
							$("#edit-appellation").val(respData.clueObj.appellation);
							$("#edit-fullname").val(respData.clueObj.fullname);
							$("#edit-job").val(respData.clueObj.job);
							$("#edit-email").val(respData.clueObj.email);
							$("#edit-phone").val(respData.clueObj.phone);
							$("#edit-website").val(respData.clueObj.website);
							$("#edit-mphone").val(respData.clueObj.mphone);
							$("#edit-state").val(respData.clueObj.state);
							$("#edit-source").val(respData.clueObj.source);
							$("#edit-description").val(respData.clueObj.description);
							$("#edit-contactSummary").val(respData.clueObj.contactSummary);
							$("#edit-nextContactTime").val(respData.clueObj.nextContactTime);
							$("#edit-address").val(respData.clueObj.address);
						}
					});

					// 打开修改线索的模态窗口
					$("#editClueModal").modal("show");
				}




			});

			// 为更新按钮绑定事件，执行线索的更新操作
			$("#updateBtn").click(function () {
				$.ajax({
					url : "workbench/clue/updateClue.do",
					data : {
						"id" : $("input[name=normalCheckBox]:checked").val(),
						"owner" : $.trim($("#edit-owner").val()),
						"company" : $.trim($("#edit-company").val()),
						"appellation" : $.trim($("#edit-appellation").val()),
						"fullname" : $.trim($("#edit-fullname").val()),
						"job" : $.trim($("#edit-job").val()),
						"email" : $.trim($("#edit-email").val()),
						"phone" : $.trim($("#edit-phone").val()),
						"website" : $.trim($("#edit-website").val()),
						"mphone" : $.trim($("#edit-mphone").val()),
						"source" : $.trim($("#edit-source").val()),
						"state" : $.trim($("#edit-state").val()),
						"description" : $.trim($("#edit-description").val()),
						"contactSummary" : $.trim($("#edit-contactSummary").val()),
						"nextContactTime" : $.trim($("#edit-nextContactTime").val()),
						"address" : $.trim($("#edit-address").val())
					},
					type : "post",
					dataType : "json",
					success : function (respData) {
						// respData 应该为 {isSuccess : true/false}
						if(respData.isSuccess){
							// 刷新列表
							showClueList(1, 2);

							// 关闭模态窗口
							$("#editClueModal").modal("hide");
						}else{
							alert("保存线索失败");
						}
					}
				})
			});


			// 当页面加载完毕后，展示线索列表
			showClueList(1, 2);

		});

		// 展示线索列表
		function showClueList(pageNo, pageSize) {

			// 每次展示列表时，先从隐藏域中取数据填入文本框中
			$("#search-fullname").val($.trim($("#hidden-fullname").val()));
			$("#search-company").val($.trim($("#hidden-company").val()));
			$("#search-phone").val($.trim($("#hidden-phone").val()));
			$("#search-source").val($.trim($("#hidden-source").val()));
			$("#search-owner").val($.trim($("#hidden-owner").val()));
			$("#search-mphone").val($.trim($("#hidden-mphone").val()));
			$("#search-state").val($.trim($("#hidden-state").val()));

			$.ajax({
				url : "workbench/clue/queryClues.do",
				data : {
					"pageNo" : pageNo,
					"pageSize" : pageSize,
					"fullname" : $.trim($("#search-fullname").val()),
					"company" : $.trim($("#search-company").val()),
					"phone" : $.trim($("#search-phone").val()),
					"source" : $.trim($("#search-source").val()),
					"owner" : $.trim($("#search-owner").val()),
					"mphone" : $.trim($("#search-mphone").val()),
					"state" : $.trim($("#search-state").val())
				},
				type : "get",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"total": xxxx, "dataList": [{线索1}, {线索2}, .....]}
					var html = "";
					$.each(respData.dataList, function (index, element) {
						html += '<tr>';
						html += '<td><input type="checkbox" value="'+ element.id +'" name="normalCheckBox"/></td>';
						html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/clue/showClueDetail.do?id='+ element.id +'\';">'+ element.fullname+element.appellation +'</a></td>';
						html += '<td>'+ element.company +'</td>';
						html += '<td>'+ element.phone +'</td>';
						html += '<td>'+ element.mphone +'</td>';
						html += '<td>'+ element.source +'</td>';
						html += '<td>'+ element.owner +'</td>';
						html += '<td>'+ element.state +'</td>';
						html += '</tr>';
					});

					// 向表格中填充数据
					$("#clueTbody").html(html);

					var totalPages = respData.total%pageSize == 0 ? respData.total/pageSize : (parseInt(respData.total/pageSize))+1;

					// 数据处理完毕后，结合分页插件，对前端展现分页信息
					$("#cluePage").bs_pagination({
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
							showClueList(data.currentPage , data.rowsPerPage);
						}
					});
				}
			});
		}

	</script>
</head>
<body>

	<!--隐藏域-->
	<input type="hidden" id="hidden-fullname">
	<input type="hidden" id="hidden-company">
	<input type="hidden" id="hidden-phone">
	<input type="hidden" id="hidden-source">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-mphone">
	<input type="hidden" id="hidden-state">

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form id="createClueForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
								  <c:forEach items="${applicationScope.appellationList}" var="dicValue">
									  <option value="${pageScope.dicValue.value}">${pageScope.dicValue.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
								  <option></option>
								  <c:forEach items="${applicationScope.clueStateList}" var="dicValue">
									  <option value=" ${pageScope.dicValue.value}">${pageScope.dicValue.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
								  <c:forEach items="${sourceList}" var="dicValue">
									  <option value="${dicValue.value}">${dicValue.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
							</div>
						</div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveBtn" class="btn btn-primary">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
								  <c:forEach items="${appellationList}" var="dicValue">
									  <option value="${dicValue.value}">${dicValue.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone">
							</div>
							<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
								  <option></option>
								  <c:forEach items="${clueStateList}" var="dicValue">
									  <option value="${dicValue.value}">${dicValue.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
									<c:forEach items="${sourceList}" var="dicValue">
										<option value="${dicValue.value}">${dicValue.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
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
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="search-company">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
					  	  <option></option>
						  <c:forEach items="${sourceList}" var="dicValue">
							  <option value="${dicValue.value}">${dicValue.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="search-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
					  	<option></option>
					    <c:forEach items="${clueStateList}" var="dicValue">
							<option value="${dicValue.value}">${dicValue.text}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" id="createBtn" class="btn btn-primary"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" id="editBtn" class="btn btn-default"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" id="deleteBtn" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input id="checkAllBox" type="checkbox" /></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueTbody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a></td>
							<td>动力节点</td>
							<td>010-84846003</td>
							<td>12345678901</td>
							<td>广告</td>
							<td>zhangsan</td>
							<td>已联系</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 60px;">
				<div id="cluePage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>