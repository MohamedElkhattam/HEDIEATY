import 'package:hedieaty/models/model/gift.dart';

class GiftSortFilterFunctionality {
  List<Gift> sortAscending(List<Gift> gifts, String sortCriteria) {
    if (sortCriteria == 'Name') {
      gifts
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sortCriteria == 'Category') {
      gifts.sort((a, b) =>
          a.category.toLowerCase().compareTo(b.category.toLowerCase()));
    }
    return gifts;
  }

  List<Gift> sortDescending(List<Gift> gifts, String sortCriteria) {
    if (sortCriteria == 'Name') {
      gifts
          .sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    } else if (sortCriteria == 'Category') {
      gifts.sort((a, b) =>
          b.category.toLowerCase().compareTo(a.category.toLowerCase()));
    }
    return gifts;
  }

  List<Gift> applyFilters({
    required List<Gift> gifts,
    String? categoryFilter,
    Status? statusFilter,
  }) {
    return gifts.where((gift) {
      bool matchesCategory = categoryFilter == null ||
          gift.category.toLowerCase() == categoryFilter.toLowerCase();
      bool matchesStatus = statusFilter == null || gift.status == statusFilter;

      return matchesCategory && matchesStatus;
    }).toList();
  }
}
