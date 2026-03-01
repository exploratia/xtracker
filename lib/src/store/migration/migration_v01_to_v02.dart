class MigrationV01ToV02 {
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    return _migrateNode(json) as Map<String, dynamic>;
  }

  static dynamic _migrateNode(dynamic node) {
    if (node is Map<String, dynamic>) {
      final Map<String, dynamic> migrated = {};

      node.forEach((key, value) {
        String newKey = key;

        if (key == 'aid') {
          newKey = 'tagId';
        } else if (key == 'attributesAttributes' || key == 'dailyLifeAttributesAttributes') {
          newKey = 'tagsTagList';
        }

        migrated[newKey] = _migrateNode(value);
      });

      return migrated;
    }

    if (node is List) {
      return node.map(_migrateNode).toList();
    }

    return node;
  }
}
