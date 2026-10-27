import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 18) {
                Text("الإعدادات")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .padding(.top, 20)
                GeoCard {
                    HStack(spacing: 14) {
                        Image(systemName: "location.north.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.geoDeep)
                            .frame(width: 72, height: 72)
                            .background(Color.geoGreen, in: RoundedRectangle(cornerRadius: 19))
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("GeoLab Personal").font(.title2.bold())
                            Text("مختبر المواقع الشخصي")
                                .foregroundStyle(.secondary)
                            Text("الإصدار التجريبي 0.2.0")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }

                SectionHeading(text: "محاكاة داخل التطبيق")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 18) {
                        Label("لا يغير إحداثيات النظام أو التطبيقات الأخرى", systemImage: "info.circle.fill")
                            .font(.caption).foregroundStyle(.secondary)
                        Toggle("حركة متدرجة", isOn: $model.smoothMovement)
                        Divider()
                        HStack {
                            Picker("نوع الخريطة", selection: $model.presentation) {
                                ForEach(MapPresentation.allCases) { option in Text(option.title).tag(option) }
                            }
                            .pickerStyle(.menu)
                        }
                        Divider()
                        Toggle("إظهار المباني ثلاثية الأبعاد", isOn: $model.show3D)
                    }
                }

                SectionHeading(text: "بيانات نموذج الاختبار")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 14) {
                        HStack {
                            Text("\(Int(model.altitude)) متر").foregroundStyle(Color.geoDeep)
                            Spacer()
                            Text("الارتفاع التجريبي")
                        }
                        Slider(value: $model.altitude, in: -100...500, step: 5)
                        Divider()
                        HStack {
                            Text("±\(Int(model.modeledAccuracy)) متر").foregroundStyle(Color.geoDeep)
                            Spacer()
                            Text("دقة الموقع التجريبي")
                        }
                        Slider(value: $model.modeledAccuracy, in: 1...100, step: 1)
                        Text("هذه القيم تُستخدم في نموذج الاختبار فقط، ولا تعدّل قراءات GPS الصادرة من iOS.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

                SectionHeading(text: "ملف المستخدم والبيانات")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 12) {
                        ValueRow(label: "المفضلة", value: "\(model.places.count) موقع")
                        Divider()
                        ValueRow(label: "المسارات", value: "\(model.routes.count) مسار")
                        Divider()
                        ValueRow(label: "اختبارات الفحص", value: "\(model.records.count) اختبار")
                        Divider()
                        ValueRow(label: "تاريخ اختيار المواقع", value: "\(model.history.count) موقع")
                        ShareLink(item: model.exportJSON()) {
                            Label("تصدير اختبارات الفحص JSON", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                SectionHeading(text: "الخصوصية")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 12) {
                        Label("بياناتك محفوظة محليًا على الجهاز", systemImage: "lock.shield.fill")
                        Label("لا توجد حسابات أو خوادم أو اشتراكات", systemImage: "wifi.slash")
                        Label("لا يطلب التطبيق صلاحية VPN أو الاقتران", systemImage: "checkmark.shield")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
    }
}
