import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';

class SearchableItemDropdown extends StatefulWidget {
  final List<Item> items;
  final Item? selectedItem;
  final ValueChanged<Item?> onChanged;
  final String? Function(Item?)? validator;
  final String hintText;

  const SearchableItemDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.validator,
    this.hintText = 'Search or select an item',
  });

  @override
  State<SearchableItemDropdown> createState() => _SearchableItemDropdownState();
}

class _SearchableItemDropdownState extends State<SearchableItemDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Item> _filteredItems = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    if (widget.selectedItem != null) {
      _controller.text = widget.selectedItem!.name;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showDropdown = true;
        _filteredItems = widget.items;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectItem(Item item) {
    setState(() {
      _controller.text = item.name;
      _showDropdown = false;
    });
    _focusNode.unfocus();
    widget.onChanged(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: widget.hintText,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _showDropdown = !_showDropdown;
                  if (_showDropdown) {
                    _filteredItems = widget.items;
                    _focusNode.requestFocus();
                  } else {
                    _focusNode.unfocus();
                  }
                });
              },
              icon: Icon(_showDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            ),
          ),
          onChanged: (value) {
            _filterItems(value);
            setState(() {
              _showDropdown = true;
            });
          },
          validator: (value) {
            if (widget.validator != null) {
              final selectedItem = widget.items
                  .where((item) => item.name.toLowerCase() == value?.toLowerCase())
                  .firstOrNull;
              return widget.validator!(selectedItem);
            }
            return null;
          },
        ),
        if (_showDropdown && _filteredItems.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  dense: true,
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  onTap: () => _selectItem(item),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}