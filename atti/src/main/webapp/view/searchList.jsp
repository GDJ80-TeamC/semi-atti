<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="atti.*" %>
<%@ page import="java.util.*" %>
<!-------------------- 
 * 기능 번호  : #25
 * 상세 설명  : 조회 및 검색 기능 // 보호자, 펫
 * 시작 날짜 : 2024-05-13
 * 담당자 : 김지훈
 -------------------->

<%
	// 현재 페이지
	System.out.println("--------------------");
	System.out.println("serchList.jsp");
%>
<!-- Controller layer  -->
<%
	// 로그인한 사용자인지 검증
	if(session.getAttribute("loginEmp") == null){
		response.sendRedirect("/atti/view/loginForm.jsp");
		return;
	}

	// 검색 시 선택한 값이 전체, 보호자, 펫인지에 대한 값
	String selectCategory = request.getParameter("selectCategory");
	if(selectCategory == null || "null".equals(selectCategory)) {
		selectCategory = "all"; // 기본값을 all로 설정
	}
	
	//System.out.println("selectCategory: " + selectCategory);
	
	// 검색 기능
	String searchWord = request.getParameter("searchWord");
	if(searchWord == null || "null".equals(searchWord)) {
		searchWord = ""; // 기본값을 공백으로 설정
	}
	
	
	// selectCategory에 따른 placeholder 분기
    String placeholder = null;
    if ("all".equals(selectCategory)) { // selectCategory가 all일 경우의 검색어
        placeholder = "펫 이름, 보호자 이름, 보호자 연락처";
    } else if ("customer".equals(selectCategory)) { // selectCategory가 customer일 경우의 검색어
        placeholder = "보호자 이름, 보호자 연락처";
    } else if ("pet".equals(selectCategory)){ // selectCategory가 pet일 경우의 검색어
		placeholder = "펫 이름, 보호자 이름";
    }
	
	//System.out.println("searchWord: " + searchWord);
	
	// 출력 리스트 페이지네이션
	// 현재 페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}

	// 페이지당 출력할 수
	int rowPerPage = 10;
	
	// 시작 페이지
	int startRow = (currentPage -1 ) * rowPerPage;

	// 전체 행의 수
	int totalRow = 0;
	// 마지막 페이지
	
	if("all".equals(selectCategory) || selectCategory == null){
		totalRow = CustomerDao.searchAllCount(searchWord);
	} else if("customer".equals(selectCategory)){
		totalRow = CustomerDao.searchCustomerCount(searchWord);
	} else if("pet".equals(selectCategory)){
		totalRow = PetDao.searchPetCount(searchWord);
	}
	
	int lastPage = totalRow / rowPerPage;
	
	// 전체 행 / 페이지당 출력할 row의 수가 0으로 나누어 떨어지지 않으면 +1
	if(totalRow % rowPerPage != 0) { // 0이 아닐 경우
		lastPage = lastPage +1; // lastPage에 1을 더한다.
	}
	
%>
<!-- model layer -->
<%
	// searchData에 각 메소드를 분기
	ArrayList<HashMap<String, Object>> searchData = new ArrayList<>();

	if("all".equals(selectCategory) || selectCategory == null){
		searchData = CustomerDao.searchAll(searchWord, startRow, rowPerPage);
	} else if("customer".equals(selectCategory)){
		searchData = CustomerDao.customerSearch(searchWord, startRow, rowPerPage);
	} else if("pet".equals(selectCategory)){
		searchData = PetDao.petSearch(searchWord, startRow, rowPerPage);
	}
	
	//System.out.println("searchData: " + searchData);
%>
<!-- view layer -->
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>고객 정보 조회</title>
	
	<!-- 부트스트랩 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
	
	<!-- CSS 공통적용CSS파일 -->
	<link rel="stylesheet" href="../css/css_all.css">
	<!-- CSS 개인 파일 -->
	<link rel="stylesheet" href="../css/css_jihoon.css">
</head>
<body id="fontSet">
	
	<!-------------------- header -------------------->
	<jsp:include page="/inc/header.jsp"></jsp:include>

	<!-------------------- aside-------------------->
	<aside>
		<!-- 서브메뉴나오는 부분 -->
		
		<div id="subMenu">
			<div id="subMenuBtnContainer">
				<button type="button" onclick="location.href='./searchList.jsp'">고객 / 펫 조회</button><br><br>
				<button type="button" onclick="location.href='./customerRegiForm.jsp'">고객 등록</button><br><br>
			
			</div>
		</div>
	</aside>
	
	<!-------------------- main -------------------->
	<main class="searchAllFormMain">
		<div>
			<h2>보호자 및 펫 조회</h2>
		</div>
		<div id="searchDiv">
			<div class="searchListForm">
				<form method="post" action="/atti/view/searchList.jsp" id="searchListForm">
					<!-- selectCategory가 all일 경우 전체를 checked -->
					<div class="searchListRadio">
					<input type="radio" name="selectCategory" id="selectCategoryAll" onchange="this.form.submit()" value="all" <%="all".equals(selectCategory) ? "checked" : ""%> class="searchFormLabel"> 
					<label for="selectCategoryAll">전체</label> 
					</div>
					<div class="searchListRadio">
					<!-- selectCategory가 customer일 경우 customer를 checked -->
					<input type="radio" name="selectCategory" id="selectCategoryCustomer" onchange="this.form.submit()" value="customer" <%="customer".equals(selectCategory) ? "checked" : ""%> class="searchFormLabel"> 
					<label for="selectCategoryCustomer">보호자</label>
					</div>
					<!-- selectCategory가 pet일 경우 pet을 checked -->
					<div class="searchListRadio">
					<input type="radio" name="selectCategory" id="selectCategoryPet" onchange="this.form.submit()" value="pet" <%="pet".equals(selectCategory) ? "checked" : ""%> class="searchFormLabel"> 
					<label for="selectCategoryPet">펫</label>
					</div>
					<input type="text" name="searchWord" class="searchFormInput" placeholder="<%=placeholder%>">
					<button type="submit" id="searchInputBtn">조회하기</button>
				</form>	
			</div>
		</div>		
			<%
				if("all".equals(selectCategory)){
			%>
					<table class="searchListTable">
						<tr>
							<th>펫 번호</th>
							<th>펫 이름</th>
							<th>보호자 이름</th>
							<th>등록일</th>
							<th>접수</th>
						</tr>
						<%
							for(HashMap<String, Object> a : searchData){
						%>		
								<tr>
									<td>
										<a href="/atti/view/customerDetail.jsp?customerNo=<%=a.get("petNo")%>">
											<%=a.get("petNo")%></a>
									</td>
									<td>
										<a href="/atti/view/petDetail.jsp?petNo=<%=a.get("petNo")%>">
											<%=a.get("petName")%>
										</a>
									</td>
									<td>
										<a href="/atti/view/customerDetail.jsp?customerNo=<%=a.get("customerNo")%>">
											<%=a.get("customerName")%>(<%=a.get("customerTel").toString().substring(7,11)%>)
											<!-- 보호자 이름(연락처 뒷자리)로 출력 -->
										</a>
									</td>
									<td><%=a.get("createDate")%></td>
									<td>
										<form method="post" action="/atti/view/regiForm.jsp">
											<input type="hidden" name="petNo" value="<%=a.get("petNo")%>">
											<input type="hidden" name="petName" value="<%=a.get("petName")%>">
											<input type="hidden" name="customerNo" value="<%=a.get("customerNo")%>">
											<input type="hidden" name="customerName" value="<%=a.get("customerName")%>">
											<input type="hidden" name="customerTel" value="<%=a.get("customerTel")%>">
											<button class="searchListBtn" type="submit">접수하기</button>
										</form>
									</td>
								</tr>
						<%
							}
						%>		
					</table>
			<%
				} else if("customer".equals(selectCategory)){
			%>
					<table class="searchListTable"">
						<tr>
							<th>보호자 번호</th>
							<th>보호자 이름</th>
							<th>등록된 펫(수)</th>
							<th>등록일</th>
						</tr>
						<%
							for(HashMap<String, Object> c : searchData){
						%>		
								<tr>
									<td>
										<a href="/atti/view/customerDetail.jsp?customerNo=<%=c.get("customerNo")%>">
											<%=c.get("customerNo")%>
										</a>
									</td>
									<td>
										<a href="/atti/view/customerDetail.jsp?customerNo=<%=c.get("customerNo")%>">
											<%=c.get("customerName")%>(<%=c.get("customerTel").toString().substring(7,11)%>)
										</a>
									</td>
									<td><%=c.get("petCnt")%></td>
									<td><%=c.get("createDate")%></td>
								</tr>
						<%
							}
						%>		
					</table>
					
					
			<%
				} else if("pet".equals(selectCategory)){
			%>
					<table class="searchListTable">
						<tr>
							<th>펫 번호</th>
							<th>펫 이름</th>
							<th>보호자 이름</th>
							<th>등록일</th>
							<th>접수</th>
						</tr>
					
						<%
							for(HashMap<String, Object> p : searchData){
						%>		
								<tr>
									<td>
										<a href="/atti/view/petDetail.jsp?petNo=<%=p.get("petNo")%>">
											<%=p.get("petNo")%>
										</a>
									</td>
									<td>
										<a href="/atti/view/petDetail.jsp?petNo=<%=p.get("petNo")%>">
											<%=p.get("petName")%>
										</a>	
									</td>
									<td>
										<a href="/atti/view/customerDetail.jsp?customerNo=<%=p.get("customerNo")%>">
											<%=p.get("customerName")%>(<%=p.get("customerTel").toString().substring(7,11)%>)
										</a>
									</td>
									<td><%=p.get("createDate")%></td>
									<td>
										<form method="post" action="/atti/view/regiForm.jsp">
											<input type="hidden" name="petNo" value="<%=p.get("petNo")%>">
											<input type="hidden" name="petName" value="<%=p.get("petName")%>">
											<input type="hidden" name="customerNo" value="<%=p.get("customerNo")%>">
											<input type="hidden" name="customerName" value="<%=p.get("customerName")%>">
											<input type="hidden" name="customerTel" value="<%=p.get("customerTel")%>">
											<button class="searchListBtn" type="submit">접수하기</button>
										</form>
									</td>
								</tr>
						<%
							}
						%>		
					</table>
			<%
				}
			%>		
		<!-- 리스트 페이지네이션 -->
		<div id="searchPagenationDiv">
			<div>
			    <!-- 이전 페이지 링크 -->
			    <% if(currentPage > 1){ %>
			        <a href="/atti/view/searchList.jsp?currentPage=<%=currentPage -1%>&selectCategory=<%=selectCategory%>&searchWord=<%=searchWord%>" class="searchPageBtn">이전</a>
			    <% } else { %>
			        <span class="searchPageBtn disabled">이전</span>
			    <% } %>
			
			    <!-- 현재 페이지 표시 -->
			    <span class="currentPage"><%=currentPage%></span>
			
			    <!-- 다음 페이지 링크 -->
			    <% if(currentPage < lastPage) { %>
			        <a href="/atti/view/searchList.jsp?currentPage=<%=currentPage +1%>&selectCategory=<%=selectCategory%>&searchWord=<%=searchWord%>" class="searchPageBtn">다음</a>
			    <% } else { %>
			        <span class="searchPageBtn disabled">다음</span>
			    <% } %>
			</div>	
		</div>

	</main>
</body>
</html>