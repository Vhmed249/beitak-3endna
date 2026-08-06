import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../providers/app_provider.dart';
import 'add_property_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    _isOwner = userId == widget.property.userId;

    final propertyId = widget.property.id;

    if (propertyId != null) {
      Future.microtask(() {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).propertyService.incrementViews(widget.property.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final propertyId = widget.property.id;
    final isFav = propertyId != null && appProvider.isFavorite(propertyId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : AppColors.white,
                ),
                onPressed: () {
                  if (propertyId != null)
                    appProvider.toggleFavorite(propertyId);
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.share, color: AppColors.white),
                onPressed: _shareProperty,
              ),
              if (_isOwner)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddPropertyScreen(property: widget.property),
                        ),
                      );
                    } else if (value == 'delete') {
                      _confirmDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('تعديل العقار')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'حذف العقار',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
              title: Text(
                widget.property.title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.property.price.toStringAsFixed(0)} ج.س',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.property.isVerified)
                            Icon(
                              Icons.verified,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          const SizedBox(width: 5),
                          Chip(
                            label: Text(
                              widget.property.rentType,
                              style: TextStyle(color: AppColors.white),
                            ),
                            backgroundColor: AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.property.address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(widget.property.city),
                        ],
                      ),

                      if (widget.property.neighborhood != null &&
                          widget.property.neighborhood!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(widget.property.neighborhood!),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(widget.property.category),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'نُشر في ${_formatDate(widget.property.createdAt)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.description,
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 15),

                  if (widget.property.rating != null)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        SizedBox(width: 5),
                        Text(
                          '${widget.property.rating!.toStringAsFixed(1)} (${widget.property.ratingCount ?? 0})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildContactSection(),
                  const SizedBox(height: 20),
                  _buildMapButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.property.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.home, size: 80, color: Colors.grey[500]),
      );
    }
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.property.imageUrls.length,
          onPageChanged: (index) {
            if (mounted) {
              setState(() => _currentImageIndex = index);
            }
          },
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () => _showFullScreenImage(index),
              child: CachedNetworkImage(
                imageUrl: widget.property.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (ctx, url, err) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1} / ${widget.property.imageUrls.length}',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: PhotoView(
                imageProvider: NetworkImage(widget.property.imageUrls[index]),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          icon: Icons.share,
          label: 'مشاركة',
          color: AppColors.primary,
          onTap: _shareProperty,
        ),
        _actionButton(
          icon: Icons.flag,
          label: 'إبلاغ',
          color: Colors.red,
          onTap: _reportProperty,
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📞 معلومات التواصل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _makePhoneCall(widget.property.phone),
                  icon: Icon(Icons.phone, color: AppColors.white),
                  label: Text(
                    'اتصال',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _sendWhatsApp(widget.property.whatsapp),
                  icon: Icon(Icons.message, color: AppColors.white),
                  label: Text(
                    'واتساب',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '📱 رقم الهاتف: ${widget.property.phone}',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            '💬 رقم واتساب: ${widget.property.whatsapp}',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: _openMap,
      icon: Icon(Icons.map, color: AppColors.white),
      label: Text(
        'عرض الموقع على الخريطة',
        style: TextStyle(color: AppColors.white, fontSize: 16),
      ),
    );
  }

  void _makePhoneCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url)))
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _sendWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.isEmpty) {
      return;
    }

    final url = 'https://wa.me/$cleanPhone';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareProperty() async {
    final link = 'https://beitak-3endna.com/property/${widget.property.id}';
    final message =
        '🏠 ${widget.property.title}\n📍 ${widget.property.address}\n💰 ${widget.property.price} ج.س\n📅 ${widget.property.rentType}\n📞 ${widget.property.phone}\n💬 ${widget.property.whatsapp}\n\nرابط الإعلان: $link';
    await Share.share(message);
  }

  void _reportProperty() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('الإبلاغ عن إعلان مخالف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل هذا الإعلان يحتوي على:'),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text('معلومات خاطئة'),
              onTap: () => _submitReport('معلومات خاطئة'),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.red),
              title: Text('صور غير حقيقية'),
              onTap: () => _submitReport('صور غير حقيقية'),
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.red),
              title: Text('سعر غير واقعي'),
              onTap: () => _submitReport('سعر غير واقعي'),
            ),
            ListTile(
              leading: Icon(Icons.person_off, color: Colors.red),
              title: Text('مالك غير موثوق'),
              onTap: () => _submitReport('مالك غير موثوق'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
        ],
      ),
    );
  }

  void _submitReport(String reason) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم إرسال البلاغ: $reason'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _openMap() async {
    final lat = widget.property.latitude;
    final lng = widget.property.longitude;
    final url = 'geo:$lat,$lng?q=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url)))
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    else {
      final fallback =
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      if (await canLaunchUrl(Uri.parse(fallback)))
        await launchUrl(
          Uri.parse(fallback),
          mode: LaunchMode.externalApplication,
        );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف العقار'),
        content: Text(
          'هل أنت متأكد من حذف هذا العقار؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AppProvider>(
                context,
                listen: false,
              ).propertyService.deleteProperty(widget.property.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم حذف العقار بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
