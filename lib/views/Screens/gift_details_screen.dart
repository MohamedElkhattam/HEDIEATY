import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/model/gift.dart';
import 'package:hedieaty/views/widgets/gift_image.dart';

class GiftDetailsScreen extends StatefulWidget {
  const GiftDetailsScreen({
    super.key,
    this.gift,
    this.onAddClick,
    this.eventLocalId,
    this.onUpdateClick,
    required this.isCurrentUser,
    required this.isEventValid,
  });
  final Gift? gift;
  final int? eventLocalId;
  final bool isEventValid;
  final bool isCurrentUser;
  final void Function()? onUpdateClick;
  final void Function(Gift gift)? onAddClick;
  @override
  State<GiftDetailsScreen> createState() => _GiftDetailsScreenState();
}

class _GiftDetailsScreenState extends State<GiftDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool isPledged = true;
  bool isUpdatable = false;
  String? selectedImagePath;
  Gift? gift;
  void _createxUpdateGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        final price = double.tryParse(_priceController.text);
        final status = isPledged ? Status.available : Status.pledged;
        if (widget.gift == null) {
          final createdGift = await GiftController.createGift(
            _nameController.text,
            _categoryController.text,
            price!,
            _descriptionController.text,
            status,
            widget.eventLocalId!,
            imagePath: selectedImagePath,
          );
          if (widget.onAddClick == null) {
            //From home create event then gift
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            //Creating Gift Directly from gift_list_screen
            widget.onAddClick!(createdGift!);
            if (!mounted) return;
            Navigator.pop(context);
          }
        } else if (widget.onUpdateClick != null && widget.gift != null) {
          await GiftController.updateExistingGift(
            _nameController.text,
            _categoryController.text,
            price!,
            _descriptionController.text,
            widget.eventLocalId!,
            widget.gift!.localId!,
            status,
            imagePath: selectedImagePath,
          );
          widget.onUpdateClick!();
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create Gift!')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating Gift: $e')),
        );
      }
    }
  }

  getUpdatedGift() async {
    gift = widget.gift?.id != null
        ? await GiftController.getUpdatedGiftFireStore(widget.gift!.id!)
        : widget.gift;
  }

  void _showImageSelected(String imagePath) {
    setState(() {
      selectedImagePath = imagePath;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUpdatedGift();
    if (widget.gift != null) {
      _nameController.text = widget.gift!.name;
      _descriptionController.text = widget.gift!.description;
      _categoryController.text = widget.gift!.category;
      _priceController.text = widget.gift!.price.toString();
      selectedImagePath = widget.gift!.imagePath;
      isPledged = gift?.status == Status.available;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('gift_details_screen'),
      appBar: AppBar(
        title: Text(
          widget.gift == null
              ? 'Create Gift🔐'
              : isUpdatable == true
                  ? 'Update Gift'
                  : widget.gift!.id == null
                      ? 'Gift Details🔐'
                      : 'Gift Details🔓',
        ),
        actions: [
          widget.isCurrentUser == true &&
                  widget.gift != null //making sure pencil not shown in create
              ? IconButton(
                  icon: Icon(Icons.edit,
                      color: widget.isEventValid ? Colors.blue : Colors.grey),
                  onPressed: () async {
                    if (!context.mounted) return;
                    if (gift!.status.name == 'pledged' ||
                        gift!.status.name == 'purchased' ||
                        !widget.isEventValid) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${gift!.status.name.toUpperCase()} Gift can\'t be updated')));
                    } else {
                      setState(() {
                        isUpdatable = true;
                      });
                    }
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: selectedImagePath != null
                        ? SizedBox(
                            width: 250,
                            height: 250,
                            child: CircleAvatar(
                              radius: 75,
                              backgroundImage: AssetImage(selectedImagePath!),
                            ),
                          )
                        : null),
                TextFormField(
                  key: const Key('gift_name'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Gift Name'),
                  readOnly: !isUpdatable && widget.gift != null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the gift name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('gift_category'),
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  readOnly: !isUpdatable && widget.gift != null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the gift category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('gift_price'),
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  readOnly: !isUpdatable && widget.gift != null,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the gift price';
                    }
                    if (num.tryParse(value) == null) {
                      return 'Please enter a valid gift price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('gift_desc'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  readOnly: !isUpdatable && widget.gift != null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the gift description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                if (widget.isCurrentUser == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPledged ? "Available" : " Pledged",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: isPledged,
                        onChanged: isUpdatable || widget.gift == null
                            ? (value) {
                                setState(() {
                                  isPledged = value;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                if (widget.isCurrentUser &&
                    (widget.gift == null || isUpdatable))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: GiftImage(onImageSelected: _showImageSelected),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          key: const Key('create_gift'),
                          onPressed: _createxUpdateGift,
                          child: Text(
                            widget.gift == null ? 'Create Gift' : 'Update Gift',
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
