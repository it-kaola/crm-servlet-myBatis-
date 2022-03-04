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

			// 为查询按钮绑定事件
			$("#searchBtn").click(function () {
				// 将数据存放在隐藏域中
				$("#hidden-owner").val($.trim($("#search-owner").val()));
				$("#hidden-name").val($.trim($("#search-name").val()));
				$("#hidden-customerId").val($.trim($("#search-customerId").val()));
				$("#hidden-stage").val($.trim($("#search-stage").val()));
				$("#hidden-type").val($.trim($("#search-type").val()));
				$("#hidden-source").val($.trim($("#search-source").val()));
				$("#hidden-contactsId").val($.trim($("#search-contactsId").val()));

				// 展现客户列表
				showTranList(1, $("#TranPage").bs_pagination('getOption', 'rowsPerPage'));
			});

			// 页面加载完毕后，展示列表
			showTranList(1, 2);

		});

		function showTranList(pageNo, pageSize) {

			// 从隐藏域中取数据
			$("#search-owner").val($("#hidden-owner").val());
			$("#search-name").val($("#hidden-name").val());
			$("#search-customerId").val($("#hidden-customerId").val());
			$("#search-stage").val($("#hidden-stage").val());
			$("#search-type").val($("#hidden-type").val());
			$("#search-source").val($("#hidden-source").val());
			$("#search-contactsId").val($("#hidden-contactsId").val());

			$.ajax({
				url : "workbench/transaction/queryTransaction.do",
				data : {
					"pageNo" : pageNo,
					"pageSize" : pageSize,
					"owner" : $.trim($("#search-owner").val()),
					"name" : $.trim($("#search-name").val()),
					"customerId" : $.trim($("#search-customerId").val()), // 需要表连接
					"stage" : $.trim($("#search-stage").val()),
					"type" : $.trim($("#search-type").val()),
					"source" : $.trim($("#search-source").val()),
					"contactsId" : $.trim($("#search-contactsId").val()) // 需要表连接
				},
				type : "get",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"total" : xxx, "dataList" : [{客户1}, {客户2}, ....] }

					var html = "";

					$.each(respData.dataList, function (index, element) {
						html += '<tr>';
						html += '<td><input type="checkbox" name="normalCheckBox" value="'+ element.id +'" /></td>';
						html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/showTranDetail.do?id='+ element.id +'\';">'+ element.name +'</a></td>';
						html += '<td>'+ element.customerId +'</td>';
						html += '<td>'+ element.stage +'</td>';
						html += '<td>'+ element.type +'</td>';
						html += '<td>'+ element.owner +'</td>';
						html += '<td>'+ element.source +'</td>';
						html += '<td>'+ element.contactsId +'</td>';
						html += '</tr>';
					});

					// 向表格中填充数据
					$("#tranListTBody").html(html);

					// 计算总页数
					var totalPages = respData.total%pageSize == 0 ? respData.total/pageSize : (parseInt(respData.total/pageSize))+1;


					// 数据处理完毕后，结合分页插件，对前端展现分页信息
					$("#TranPage").bs_pagination({
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
						showTranList(data.currentPage , data.rowsPerPage);
						}
					});
				}
			});

		}


	</script>
</head>
<body>

	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-name"/>
	<input type="hidden" id="hidden-customerId"/>
	<input type="hidden" id="hidden-type"/>
	<input type="hidden" id="hidden-stage"/>
	<input type="hidden" id="hidden-source"/>
	<input type="hidden" id="hidden-contactsId"/>

	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
					    <c:forEach items="${stageList}" var="dicVal">
							<option value="${dicVal.value}">${dicVal.text}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						  <c:forEach items="${transactionTypeList}" var="dicVal">
							  <option value="${dicVal.value}">${dicVal.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${sourceList}" var="dicVal">
							  <option value="${dicVal.value}">${dicVal.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsId">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/createTran.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/edit.jsp';"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tranListTBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">动力节点-交易01</a></td>
							<td>动力节点</td>
							<td>谈判/复审</td>
							<td>新业务</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>李四</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">动力节点-交易01</a></td>
                            <td>动力节点</td>
                            <td>谈判/复审</td>
                            <td>新业务</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>李四</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;">
				<div id="TranPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>