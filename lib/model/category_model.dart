class Category {
  final String id;
  final String title;
  final bool showing;
  bool selected;

  Category({
    required this.id,
    required this.title,
    required this.showing,
    required this.selected
  });

  Category.formJson(Map<String, dynamic> json)
    : id = json['_id'],
      title = json['name'],
      showing = true,
      selected = false;
}

List<Category> categoryTest = [
  Category(id: '0', title: 'ทั้งหมด', showing: true, selected: true),
  Category(id: '1', title: 'กาแฟ', showing: true, selected: false ),
  Category(id: '2', title: 'โกโก้', showing: true, selected: false ),
  Category(id: '3', title: 'ติ่มซำ', showing: true, selected: false),
  Category(id: '4', title: 'อาหาร', showing: true, selected: false ),
  Category(id: '5', title: 'ของทอด', showing: true, selected: false ),
  Category(id: '6', title: 'อื่น ๆ', showing: true, selected: false )
];