# MovieSearchApp 🍿
MovieSearchApp은 최근 인기있는 영화나 그 동안 개봉한 영화 중 평점이 높은 영화 및 사용자의 관심 장르에 따라 영화 목록을 보여 주고, 궁금한 영화를 검색하고 북마크에 저장해서 관심있는 영화를 확인할 수 있는 앱 입니다.

# 기능 ⚙️
1. 최근 인기 영화, 평점 높은 영화, 개봉 예정 영화 목록 확인
2. 제목 기반의 영화 검색 기능(장르, 감독, 출연 배우 등 추가 예정)
3. 영화 북마크 및 북마크 목록 확인 가능

# Stacks 📚
## UIKit, MVVM
-
## Combine, Swift Cuncurrency
- MVVM 패턴으로 데이터 바인딩과 영화 검색, 북마크 저장과 같은 데이터 처리 후 동적으로 화면을 처리하기 위해서 Combine을 사용하였습니다.
- URLRequest를 통해 가져온 데이터 중 영화 포스터 이미지를 Concurrency를 통해 불러와 화면에 보여줬습니다.
## CoreData
- 최근 검색어의 저장 및 검색한 영화를 북마크에서 관리하기 위해 CoreData를 사용했습니다.
## 예정
1. URLRequest -> Alamofire
2. Image load cuncurrency -> Kingfisher
3. NSLayoutConstraint -> SnapKit