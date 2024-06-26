package atti;

import java.sql.*;
import java.util.*;

public class ExaminationDao {

	/*
	 * 메소드 : ExaminationDao#examinationList() 
	 * 페이지 : examinationList.jsp
	 * 시작 날짜 : 2024-05-10
	 * 담당자 : 한은혜 
	 */
	public static ArrayList<HashMap<String, Object>> examinationList(String searchDate, int startRow, int rowPerPage) throws Exception{
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		// DB연결
		Connection conn = DBHelper.getConnection();
		
		// 디버깅 
		//System.out.println(searchDate + " ====== ExaminationDao#examinationList searchDate");
		//System.out.println(startRow + " ====== ExaminationDao#examinationList startRow");
		//System.out.println(rowPerPage + " ====== ExaminationDao#examinationList rowPerPage");
		
		/*
		 * 검사 리스트 출력 쿼리 
		 * 검사 리스트 검사 정보(examination_no, examinationKind, examination_content, examination_date) 
		 * + 반려 동물 정보(pet_kind, pet_name) 
		 * + 총 행 수 세기(페이징)
		 * + 검사 날짜 내림차순(최신순) 
		 * + 페이징
		 */
		String sql = "SELECT"
				+ " examination_no examinationNo, examination_kind examinationKind, examination_content examinationContent, examination_date examinationDate,"
				+ " pet_kind petKind, pet_name petName, "
				+ " (SELECT COUNT(examination_no) FROM examination"
				+ " WHERE DATE(examination_date) LIKE ?) totalRow"	// 총 행 수(페이징)
				+ " FROM examination e"
				+ " LEFT JOIN registration r"
				+ " ON e.regi_no = r.regi_no"						// 검사한 접수 번호 = 접수한 접수 번호 
				+ " LEFT JOIN pet p"
				+ " ON r.pet_no = p.pet_no"							// 접수한 반려동물 번호 = 동물 반려동물 번호 
				+ " WHERE DATE(examination_date) LIKE ?"			// 검색(선택)한 검사 날
				+ " ORDER BY examination_date DESC"					// 내림차순으로 정렬(최신순)
				+ " LIMIT ? , ?"; 									// 페이징
				
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setString(1, "%" + searchDate + "%");
		stmt.setString(2, "%" + searchDate + "%");
		stmt.setInt(3, startRow);
		stmt.setInt(4, rowPerPage);
		
		//System.out.println(stmt + " ====== ExaminationDao#examinationList stmt");
		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			HashMap<String, Object> e = new HashMap<String, Object>();
			e.put("petKind", rs.getString("petKind"));							// 반려동물 종류
			e.put("petName", rs.getString("petName"));							// 반려동물 이름 
			e.put("examinationNo", rs.getInt("examinationNo"));					// 검사 번호 
			e.put("examinationKind", rs.getString("examinationKind"));			// 검사 종류
			e.put("examinationContent", rs.getString("examinationContent"));	// 검사 내용
			e.put("examinationDate", rs.getString("examinationDate"));			// 검사 날짜 
			e.put("totalRow", rs.getInt("totalRow"));							// 총 행 수(페이징)
			
			list.add(e);
		}
		conn.close();
		return list;
	}
	
	/*
	 * 메소드 : ExaminationDao#examinationDetail()
	 * 페이지 : examinationDetail.jsp
	 * 시작 날짜 : 2024-05-10
	 * 담당자 : 한은혜 
	 */
	public static ArrayList<HashMap<String, Object>> examinationDetail(int examinationNo) throws Exception{
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		// DB연결
		Connection conn = DBHelper.getConnection();
		// 받아온 값 확인 
		//System.out.println(examinationNo + " ====== ExaminationDao#examinationDetail examinationNo");
		
		/*
		 * 검사 상세보기 쿼리 
		 * 검사 정보(examination_no, examinationKind, examination_content, file_name, examination_date)
		 * + 반려 동물 정보(pet_kind, pet_name)
		*/
		String sql = "SELECT"
				+ " e.examination_no examinationNo, examination_kind examinationKind, examination_content examinationContent, file_name fileName, examination_date examinationDate,"
				+ " pet_kind petKind, pet_name petName "
				+ " FROM examination e"
				+ " LEFT JOIN registration r"
				+ " ON e.regi_no = r.regi_no"
				+ " LEFT JOIN pet p"
				+ " ON r.pet_no = p.pet_no"
				+ " WHERE e.examination_no = ?";
				
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, examinationNo);
		//System.out.println(stmt + " ====== ExaminationDao#examinationDetail stmt");
		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			HashMap<String, Object> d = new HashMap<String, Object>();
			d.put("fileName", rs.getString("fileName"));						// 사진 이름(파일이름)
			d.put("petKind", rs.getString("petKind"));							// 반려동물 종류
			d.put("petName", rs.getString("petName"));							// 반려동물 이름
			d.put("examinationNo", rs.getInt("examinationNo"));					// 검사 번호
			d.put("examinationKind", rs.getString("examinationKind"));			// 검사 종류
			d.put("examinationContent", rs.getString("examinationContent"));	// 검사 내용
			d.put("examinationDate", rs.getString("examinationDate"));			// 검사 날짜 
		
			list.add(d);
		}
		conn.close();
		return list;
	}
	
	/*
	 * 메소드 : ExaminationDao#examinationInsert()
	 * 페이지 : clinicDetailForm.jsp
	 * 시작 날짜 : 2024-05-26
	 * 담당자 : 한은혜 
	 */
	public static int examinationInsert(int regiNo, String examinationKind, String examinationContent, String fileName) throws Exception{
		
		int insertRow = 0;
		// DB연결
		Connection conn = DBHelper.getConnection();
		// 받아온 값 확인 
		System.out.println(regiNo + " ====== ExaminationDao#examinationInsert regiNo");
		
		String sql ="INSERT INTO examination"
				+ " 	(regi_no, examination_kind, examination_content, file_name, examination_date)"
				+ " 	VALUES(?, ?, ?, ?, NOW())";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, regiNo);
		stmt.setString(2, examinationKind);
		stmt.setString(3, examinationContent);
		stmt.setString(4, fileName);
		
		System.out.println(stmt + " ====== ExaminationDao#examinationInsert() stmt");

		insertRow = stmt.executeUpdate();
		System.out.println(insertRow + " ====== ExaminationDao#examinationInsert() insertRow");

		conn.close();
		return insertRow;
	}
	
	
	/*
	 * 메소드 : ExaminationDao#examinationUpdate()
	 * 페이지 : clinicDetailForm.jsp
	 * 시작 날짜 : 2024-05-27
	 * 담당자 : 한은혜 
	 */
	public static int examinationUpdate(int regiNo, String examinationKind, String examinationContent, String fileName, int examinationNo) throws Exception{
		
		int updateRow = 0;
		// DB연결
		Connection conn = DBHelper.getConnection();
		// 받아온 값 확인 
		System.out.println(regiNo + " ====== ExaminationDao#examinationUpdate regiNo");
		System.out.println(examinationNo + " 2222====== ExaminationDao#examinationUpdate examinationNo");
		
		String sql ="UPDATE examination "
				+ " SET examination_kind = ?, examination_content = ?, file_name = ?, examination_date = NOW()"
				+ " WHERE regi_no = ?"
				+ " AND examination_no = ?";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setString(1, examinationKind);
		stmt.setString(2, examinationContent);
		stmt.setString(3, fileName);
		stmt.setInt(4, regiNo);
		stmt.setInt(5, examinationNo);
		System.out.println(stmt + " ====== ExaminationDao#examinationUpdate() stmt");

		updateRow = stmt.executeUpdate();
		System.out.println(updateRow + " ====== ExaminationDao#examinationUpdate() updateRow");

		conn.close();
		return updateRow;
	}
	
	/*
	 * 메소드 : ExaminationDao#examinationInfo()
	 * 페이지 : clinicDetailForm.jsp
	 * 시작 날짜 : 2024-05-28
	 * 담당자 : 한은혜 
	 */
	public static ArrayList<HashMap<String, Object>> examinationInfo(int regiNo) throws Exception{
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		// DB연결
		Connection conn = DBHelper.getConnection();
		// 받아온 값 확인 
		//System.out.println(examinationNo + " ====== ExaminationDao#examinationDetail examinationNo");
		
		/*
		 * 검사 정보 쿼리 
		 * 검사 정보(examination_no, examinationKind, examination_content, file_name, examination_date)
		*/
		String sql = "SELECT"
				+ " e.examination_no examinationNo, examination_kind examinationKind, examination_content examinationContent, file_name fileName, examination_date examinationDate"
				+ " FROM examination e"
				+ " LEFT JOIN registration r"
				+ " ON e.regi_no = r.regi_no"
				+ " WHERE e.regi_no = ?"
				+ " ORDER BY examination_date ASC";
				
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, regiNo);
		//System.out.println(stmt + " ====== ExaminationDao#examinationInfo stmt");
		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			HashMap<String, Object> d = new HashMap<String, Object>();
			d.put("fileName", rs.getString("fileName"));						// 파일 이름
			d.put("examinationNo", rs.getInt("examinationNo"));					// 검사 번호
			d.put("examinationKind", rs.getString("examinationKind"));			// 검사 종류
			d.put("examinationContent", rs.getString("examinationContent"));	// 검사 내용
			d.put("examinationDate", rs.getString("examinationDate"));			// 검사 날짜 
		
			list.add(d);
		}
		conn.close();
		return list;
	}
	
	/*
	 * 메소드 : ExaminationDao#examinationType()
	 * 페이지 : clinicDetailForm.jsp
	 * 시작 날짜 : 2024-05-28
	 * 담당자 : 한은혜 
	 */
	public static ArrayList<HashMap<String, Object>> examinationType() throws Exception{
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		// DB연결
		Connection conn = DBHelper.getConnection();
		
		
		String sql = "SELECT examination_kind examinationKind, examination_cost examinationCost"
				+ " FROM examination_kind";
		PreparedStatement stmt = conn.prepareStatement(sql);
		//System.out.println(stmt + " ====== ExaminationDao#examinationType stmt");

		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			HashMap<String, Object> e = new HashMap<String, Object>();
			e.put("examinationKind", rs.getString("examinationKind"));	
			e.put("examinationCost", rs.getString("examinationCost"));	
			
			list.add(e);
		}
		conn.close();
		return list;
	}
}
