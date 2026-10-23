-- CreateEnum
CREATE TYPE "ProductFulfillmentKind" AS ENUM ('standard', 'packaged_food', 'fresh_food');

-- CreateEnum
CREATE TYPE "ProductStatus" AS ENUM ('draft', 'active', 'archived');

-- CreateEnum
CREATE TYPE "CategoryBrandPolicy" AS ENUM ('hidden', 'optional', 'required', 'default_store');

-- CreateEnum
CREATE TYPE "ProductAttributeType" AS ENUM ('text', 'number', 'boolean', 'color');

-- CreateEnum
CREATE TYPE "CategoryAttributeScope" AS ENUM ('product', 'variant', 'batch');

-- CreateEnum
CREATE TYPE "AttributeInputType" AS ENUM ('text', 'textarea', 'number', 'boolean', 'select', 'multiselect', 'color', 'date');

-- CreateEnum
CREATE TYPE "WeightUnit" AS ENUM ('g', 'kg', 'lb', 'oz');

-- CreateEnum
CREATE TYPE "DiscountType" AS ENUM ('percentage', 'fixed_amount');

-- CreateEnum
CREATE TYPE "InventoryBatchDisposition" AS ENUM ('sellable', 'quarantined', 'unsafe');

-- CreateEnum
CREATE TYPE "InventoryMovementType" AS ENUM ('purchase', 'sale_reserve', 'sale_commit', 'reservation_release', 'return', 'adjustment', 'transfer_in', 'transfer_out');

-- CreateEnum
CREATE TYPE "StockReservationStatus" AS ENUM ('active', 'committed', 'released', 'expired', 'restocked');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('pending', 'confirmed', 'processing', 'completed', 'cancelled');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('unpaid', 'authorized', 'partially_paid', 'paid', 'partially_refunded', 'refunded', 'failed');

-- CreateEnum
CREATE TYPE "DeliveryStatus" AS ENUM ('unfulfilled', 'preparing', 'ready_to_ship', 'shipped', 'out_for_delivery', 'delivered', 'returned', 'failed');

-- CreateEnum
CREATE TYPE "OrderInventoryStatus" AS ENUM ('reserved', 'committed', 'released', 'restocked');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('cash_on_delivery', 'manual_bank', 'manual_mobile', 'online_gateway');

-- CreateEnum
CREATE TYPE "OrderStatusEventType" AS ENUM ('order', 'payment', 'delivery');

-- CreateEnum
CREATE TYPE "OrderAddressType" AS ENUM ('shipping', 'billing');

-- CreateEnum
CREATE TYPE "OrderPaymentEntryType" AS ENUM ('receipt', 'reversal');

-- CreateEnum
CREATE TYPE "OrderRecoveryDisposition" AS ENUM ('awaiting_inspection', 'sellable', 'unsafe');

-- CreateEnum
CREATE TYPE "StoreSeoPage" AS ENUM ('home', 'about');

-- CreateTable
CREATE TABLE "activity_event" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "actorUserId" TEXT,
    "targetUserId" TEXT,
    "visitorId" TEXT,
    "severity" TEXT NOT NULL DEFAULT 'info',
    "message" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "activity_event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "image" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "twoFactorEnabled" BOOLEAN NOT NULL DEFAULT false,
    "banned" BOOLEAN NOT NULL DEFAULT false,
    "banReason" TEXT,
    "archived" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invitation" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "roleId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "inviterId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invitation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "session" (
    "id" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "token" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "userId" TEXT NOT NULL,

    CONSTRAINT "session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_auth_method" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "method" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_auth_method_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "idToken" TEXT,
    "accessTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenExpiresAt" TIMESTAMP(3),
    "scope" TEXT,
    "password" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "twoFactor" (
    "id" TEXT NOT NULL,
    "secret" TEXT NOT NULL,
    "backupCodes" TEXT NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "twoFactor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_settings" (
    "id" TEXT NOT NULL,
    "passwordSignInEnabled" BOOLEAN NOT NULL DEFAULT true,
    "passwordSignUpEnabled" BOOLEAN NOT NULL DEFAULT true,
    "githubSignInEnabled" BOOLEAN NOT NULL DEFAULT true,
    "githubSignUpEnabled" BOOLEAN NOT NULL DEFAULT true,
    "googleSignInEnabled" BOOLEAN NOT NULL DEFAULT true,
    "googleSignUpEnabled" BOOLEAN NOT NULL DEFAULT true,
    "magicLinkSignInEnabled" BOOLEAN NOT NULL DEFAULT true,
    "magicLinkSignUpEnabled" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category" (
    "archivedAt" TIMESTAMP(3),
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "parentId" TEXT,
    "imageUrl" TEXT,
    "iconUrl" TEXT,
    "fulfillmentKind" "ProductFulfillmentKind" NOT NULL DEFAULT 'standard',
    "brandPolicy" "CategoryBrandPolicy" NOT NULL DEFAULT 'optional',
    "showStoreBrand" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_brand" (
    "archivedAt" TIMESTAMP(3),
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "logoUrl" TEXT,
    "websiteUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_brand_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product" (
    "archivedAt" TIMESTAMP(3),
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "descriptionHtml" TEXT,
    "categoryId" TEXT NOT NULL,
    "brandId" TEXT,
    "status" "ProductStatus" NOT NULL DEFAULT 'draft',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "isTrending" BOOLEAN NOT NULL DEFAULT false,
    "badgeLabel" TEXT,
    "coverImageUrl" TEXT,
    "searchKeywords" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_variant" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "barcode" TEXT,
    "name" TEXT NOT NULL,
    "attributesSnapshot" JSONB,
    "price" DECIMAL(12,2) NOT NULL,
    "compareAtPrice" DECIMAL(12,2),
    "costPrice" DECIMAL(12,2),
    "currency" TEXT NOT NULL DEFAULT 'BDT',
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "imageUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "weightValue" DECIMAL(10,3),
    "weightUnit" "WeightUnit",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_variant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_highlight" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "iconUrl" TEXT,
    "imageUrl" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_highlight_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_attribute" (
    "archivedAt" TIMESTAMP(3),
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "type" "ProductAttributeType" NOT NULL DEFAULT 'text',
    "filterable" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_attribute_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_attribute_value" (
    "id" TEXT NOT NULL,
    "attributeId" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_attribute_value_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_variant_attribute_value" (
    "variantId" TEXT NOT NULL,
    "attributeValueId" TEXT NOT NULL,

    CONSTRAINT "product_variant_attribute_value_pkey" PRIMARY KEY ("variantId","attributeValueId")
);

-- CreateTable
CREATE TABLE "category_attribute" (
    "id" TEXT NOT NULL,
    "categoryId" TEXT NOT NULL,
    "attributeId" TEXT NOT NULL,
    "scope" "CategoryAttributeScope" NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT false,
    "filterable" BOOLEAN NOT NULL DEFAULT false,
    "variantDefining" BOOLEAN NOT NULL DEFAULT false,
    "comparable" BOOLEAN NOT NULL DEFAULT false,
    "inputType" "AttributeInputType" NOT NULL DEFAULT 'text',
    "unit" TEXT,
    "groupName" TEXT,
    "helpText" TEXT,
    "placeholder" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "category_attribute_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_attribute_assignment" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "attributeId" TEXT NOT NULL,
    "attributeValueId" TEXT,
    "rawText" TEXT,
    "rawNumber" DECIMAL(16,4),
    "rawBoolean" BOOLEAN,
    "rawDate" TIMESTAMP(3),
    "displayValue" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "product_attribute_assignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_attribute_assignment_value" (
    "assignmentId" TEXT NOT NULL,
    "attributeValueId" TEXT NOT NULL,

    CONSTRAINT "product_attribute_assignment_value_pkey" PRIMARY KEY ("assignmentId","attributeValueId")
);

-- CreateTable
CREATE TABLE "ecommerce_customer" (
    "id" TEXT NOT NULL,
    "normalizedEmail" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT,
    "adminNote" TEXT,
    "userId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ecommerce_customer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "discount_code" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT,
    "type" "DiscountType" NOT NULL,
    "value" DECIMAL(12,2) NOT NULL,
    "currency" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "startsAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "minimumOrderAmount" DECIMAL(12,2),
    "totalUsageLimit" INTEGER,
    "perCustomerUsageLimit" INTEGER,
    "usageCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "discount_code_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "discount_redemption" (
    "id" TEXT NOT NULL,
    "discountCodeId" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "customerKey" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "discount_redemption_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "contactName" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "address" TEXT,
    "notes" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "supplier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_location" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "address" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "inventory_location_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_batch" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "supplierId" TEXT,
    "batchNumber" TEXT,
    "disposition" "InventoryBatchDisposition" NOT NULL DEFAULT 'sellable',
    "expiryDate" TIMESTAMP(3),
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "unitCost" DECIMAL(12,4),
    "notes" TEXT,

    CONSTRAINT "inventory_batch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_batch_attribute_assignment" (
    "id" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "attributeId" TEXT NOT NULL,
    "attributeValueId" TEXT,
    "rawText" TEXT,
    "rawNumber" DECIMAL(16,4),
    "rawBoolean" BOOLEAN,
    "rawDate" TIMESTAMP(3),
    "displayValue" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "inventory_batch_attribute_assignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_stock" (
    "id" TEXT NOT NULL,
    "stockKey" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "locationId" TEXT NOT NULL,
    "batchId" TEXT,
    "quantityOnHand" INTEGER NOT NULL DEFAULT 0,
    "quantityReserved" INTEGER NOT NULL DEFAULT 0,
    "reorderLevel" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "inventory_stock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_movement" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "locationId" TEXT NOT NULL,
    "batchId" TEXT,
    "type" "InventoryMovementType" NOT NULL,
    "delta" INTEGER NOT NULL,
    "unitCost" DECIMAL(12,4),
    "reason" TEXT,
    "referenceType" TEXT,
    "referenceId" TEXT,
    "actorUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "inventory_movement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_reservation" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "locationId" TEXT NOT NULL,
    "batchId" TEXT,
    "quantity" INTEGER NOT NULL,
    "status" "StockReservationStatus" NOT NULL DEFAULT 'active',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "referenceType" TEXT,
    "referenceId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "stock_reservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order" (
    "id" TEXT NOT NULL,
    "orderNumber" TEXT NOT NULL,
    "checkoutKey" TEXT,
    "userId" TEXT,
    "customerName" TEXT NOT NULL,
    "customerEmail" TEXT NOT NULL,
    "customerPhone" TEXT,
    "ecommerceCustomerId" TEXT,
    "subtotalAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "discountAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "discountCodeId" TEXT,
    "discountCodeSnapshot" TEXT,
    "discountDescriptionSnapshot" TEXT,
    "discountTypeSnapshot" "DiscountType",
    "discountValueSnapshot" DECIMAL(12,2),
    "taxAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "shippingAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "totalAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'BDT',
    "paymentMethod" "PaymentMethod" NOT NULL DEFAULT 'cash_on_delivery',
    "orderStatus" "OrderStatus" NOT NULL DEFAULT 'pending',
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'unpaid',
    "deliveryStatus" "DeliveryStatus" NOT NULL DEFAULT 'unfulfilled',
    "inventoryStatus" "OrderInventoryStatus" NOT NULL DEFAULT 'reserved',
    "stockReservedUntil" TIMESTAMP(3),
    "stockCommittedAt" TIMESTAMP(3),
    "stockReleasedAt" TIMESTAMP(3),
    "shippingRateId" TEXT,
    "shippingMethodCode" TEXT,
    "shippingMethodLabel" TEXT,
    "fulfillmentNote" TEXT,
    "shippedAt" TIMESTAMP(3),
    "deliveredAt" TIMESTAMP(3),
    "customerNotes" TEXT,
    "adminNotes" TEXT,
    "placedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_refund" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "note" TEXT,
    "restockInventory" BOOLEAN NOT NULL DEFAULT false,
    "actorUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_refund_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_address" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "type" "OrderAddressType" NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "line1" TEXT NOT NULL,
    "line2" TEXT,
    "city" TEXT,
    "state" TEXT,
    "postalCode" TEXT,
    "country" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "order_address_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_line_item" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "productId" TEXT,
    "variantId" TEXT,
    "productName" TEXT NOT NULL,
    "variantName" TEXT,
    "sku" TEXT,
    "imageUrl" TEXT,
    "attributesSnapshot" JSONB,
    "fulfillmentKind" "ProductFulfillmentKind" NOT NULL DEFAULT 'standard',
    "quantity" INTEGER NOT NULL,
    "unitPrice" DECIMAL(12,2) NOT NULL,
    "discountAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "taxAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "subtotalAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "totalAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "order_line_item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_status_event" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "type" "OrderStatusEventType" NOT NULL,
    "previousValue" TEXT,
    "newValue" TEXT NOT NULL,
    "note" TEXT,
    "metadata" JSONB,
    "actorUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_status_event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_payment" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "entryType" "OrderPaymentEntryType" NOT NULL DEFAULT 'receipt',
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL,
    "method" "PaymentMethod" NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "reference" TEXT,
    "note" TEXT,
    "actorUserId" TEXT NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reversesId" TEXT,

    CONSTRAINT "order_payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_recovery" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL,
    "receivedByUserId" TEXT NOT NULL,
    "receiptNote" TEXT NOT NULL,
    "disposition" "OrderRecoveryDisposition" NOT NULL DEFAULT 'awaiting_inspection',
    "inspectedAt" TIMESTAMP(3),
    "inspectedByUserId" TEXT,
    "inspectionNote" TEXT,
    "restockedAt" TIMESTAMP(3),
    "restockedByUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "order_recovery_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "store_settings" (
    "id" TEXT NOT NULL DEFAULT 'default',
    "storeName" TEXT NOT NULL,
    "supportEmail" TEXT,
    "supportPhone" TEXT,
    "defaultCurrency" TEXT NOT NULL DEFAULT 'BDT',
    "orderNumberPrefix" TEXT NOT NULL DEFAULT 'ORD',
    "reservationDurationMinutes" INTEGER NOT NULL DEFAULT 30,
    "checkoutEnabled" BOOLEAN NOT NULL DEFAULT true,
    "checkoutNotice" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "store_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "store_page_seo" (
    "page" "StoreSeoPage" NOT NULL,
    "revision" INTEGER NOT NULL DEFAULT 1,
    "title" VARCHAR(120),
    "description" VARCHAR(320),
    "imageUrl" VARCHAR(2048),
    "publishedTitle" VARCHAR(120),
    "publishedDescription" VARCHAR(320),
    "publishedImageUrl" VARCHAR(2048),
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "store_page_seo_pkey" PRIMARY KEY ("page")
);

-- CreateTable
CREATE TABLE "shipping_rate" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'BDT',
    "freeOverAmount" DECIMAL(12,2),
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "tier" TEXT NOT NULL DEFAULT 'standard',
    "destinationRules" JSONB,
    "minimumOrderAmount" DECIMAL(12,2),
    "maximumOrderAmount" DECIMAL(12,2),
    "archivedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "shipping_rate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feedback" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "severity" TEXT NOT NULL DEFAULT 'low',
    "status" TEXT NOT NULL DEFAULT 'open',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "feedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "url" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rate_limit_settings" (
    "id" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "publicEnabled" BOOLEAN NOT NULL DEFAULT true,
    "publicWindowSeconds" INTEGER NOT NULL DEFAULT 60,
    "publicMaxRequests" INTEGER NOT NULL DEFAULT 60,
    "authEnabled" BOOLEAN NOT NULL DEFAULT true,
    "authWindowSeconds" INTEGER NOT NULL DEFAULT 60,
    "authMaxRequests" INTEGER NOT NULL DEFAULT 10,
    "protectedEnabled" BOOLEAN NOT NULL DEFAULT true,
    "protectedWindowSeconds" INTEGER NOT NULL DEFAULT 60,
    "protectedMaxRequests" INTEGER NOT NULL DEFAULT 120,
    "adminEnabled" BOOLEAN NOT NULL DEFAULT true,
    "adminWindowSeconds" INTEGER NOT NULL DEFAULT 60,
    "adminMaxRequests" INTEGER NOT NULL DEFAULT 300,
    "specialEnabled" BOOLEAN NOT NULL DEFAULT true,
    "specialWindowSeconds" INTEGER NOT NULL DEFAULT 60,
    "specialMaxRequests" INTEGER NOT NULL DEFAULT 30,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "rate_limit_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rbac_permission" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "group" TEXT,
    "isSystem" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rbac_permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rbac_role" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "scope" TEXT NOT NULL DEFAULT 'platform',
    "isSystem" BOOLEAN NOT NULL DEFAULT true,
    "isProtected" BOOLEAN NOT NULL DEFAULT false,
    "seedVersion" INTEGER NOT NULL DEFAULT 1,
    "customizedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "rbac_role_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rbac_role_permission" (
    "roleId" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,

    CONSTRAINT "rbac_role_permission_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "rbac_user_role" (
    "userId" TEXT NOT NULL,
    "roleId" TEXT NOT NULL,

    CONSTRAINT "rbac_user_role_pkey" PRIMARY KEY ("userId","roleId")
);

-- CreateTable
CREATE TABLE "rbac_user_permission_override" (
    "userId" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,
    "effect" TEXT NOT NULL,

    CONSTRAINT "rbac_user_permission_override_pkey" PRIMARY KEY ("userId","permissionId","effect")
);

-- CreateTable
CREATE TABLE "visitor_identity" (
    "id" TEXT NOT NULL,
    "visitorId" TEXT NOT NULL,
    "firstSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "firstUserId" TEXT,
    "lastUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "visitor_identity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "visitor_session" (
    "id" TEXT NOT NULL,
    "visitorIdentityId" TEXT NOT NULL,
    "userId" TEXT,
    "isBot" BOOLEAN NOT NULL DEFAULT false,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "entryPath" TEXT NOT NULL,
    "lastPath" TEXT NOT NULL,
    "referrer" TEXT,
    "deviceType" TEXT,
    "country" TEXT,
    "ipHash" TEXT,
    "eventCount" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "visitor_session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_event" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'processing',
    "attemptCount" INTEGER NOT NULL DEFAULT 1,
    "errorMessage" TEXT,
    "processedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "webhook_event_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "activity_event_createdAt_idx" ON "activity_event"("createdAt");

-- CreateIndex
CREATE INDEX "activity_event_type_createdAt_idx" ON "activity_event"("type", "createdAt");

-- CreateIndex
CREATE INDEX "activity_event_actorUserId_createdAt_idx" ON "activity_event"("actorUserId", "createdAt");

-- CreateIndex
CREATE INDEX "activity_event_targetUserId_createdAt_idx" ON "activity_event"("targetUserId", "createdAt");

-- CreateIndex
CREATE INDEX "user_createdAt_idx" ON "user"("createdAt");

-- CreateIndex
CREATE INDEX "user_banned_idx" ON "user"("banned");

-- CreateIndex
CREATE INDEX "user_archived_idx" ON "user"("archived");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE INDEX "invitation_email_idx" ON "invitation"("email");

-- CreateIndex
CREATE INDEX "invitation_status_idx" ON "invitation"("status");

-- CreateIndex
CREATE INDEX "invitation_expiresAt_idx" ON "invitation"("expiresAt");

-- CreateIndex
CREATE INDEX "invitation_roleId_idx" ON "invitation"("roleId");

-- CreateIndex
CREATE INDEX "session_userId_idx" ON "session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "session_token_key" ON "session"("token");

-- CreateIndex
CREATE INDEX "user_auth_method_method_idx" ON "user_auth_method"("method");

-- CreateIndex
CREATE UNIQUE INDEX "user_auth_method_userId_method_key" ON "user_auth_method"("userId", "method");

-- CreateIndex
CREATE INDEX "account_userId_idx" ON "account"("userId");

-- CreateIndex
CREATE INDEX "verification_identifier_idx" ON "verification"("identifier");

-- CreateIndex
CREATE INDEX "twoFactor_secret_idx" ON "twoFactor"("secret");

-- CreateIndex
CREATE INDEX "twoFactor_userId_idx" ON "twoFactor"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "category_slug_key" ON "category"("slug");

-- CreateIndex
CREATE INDEX "category_parentId_idx" ON "category"("parentId");

-- CreateIndex
CREATE INDEX "category_isActive_idx" ON "category"("isActive");

-- CreateIndex
CREATE INDEX "category_isFeatured_idx" ON "category"("isFeatured");

-- CreateIndex
CREATE INDEX "category_sortOrder_idx" ON "category"("sortOrder");

-- CreateIndex
CREATE INDEX "category_archivedAt_idx" ON "category"("archivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "product_brand_slug_key" ON "product_brand"("slug");

-- CreateIndex
CREATE INDEX "product_brand_isActive_idx" ON "product_brand"("isActive");

-- CreateIndex
CREATE INDEX "product_brand_isFeatured_idx" ON "product_brand"("isFeatured");

-- CreateIndex
CREATE INDEX "product_brand_archivedAt_idx" ON "product_brand"("archivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "product_slug_key" ON "product"("slug");

-- CreateIndex
CREATE INDEX "product_categoryId_idx" ON "product"("categoryId");

-- CreateIndex
CREATE INDEX "product_brandId_idx" ON "product"("brandId");

-- CreateIndex
CREATE INDEX "product_status_idx" ON "product"("status");

-- CreateIndex
CREATE INDEX "product_isActive_idx" ON "product"("isActive");

-- CreateIndex
CREATE INDEX "product_isFeatured_idx" ON "product"("isFeatured");

-- CreateIndex
CREATE INDEX "product_isTrending_idx" ON "product"("isTrending");

-- CreateIndex
CREATE INDEX "product_archivedAt_idx" ON "product"("archivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "product_variant_sku_key" ON "product_variant"("sku");

-- CreateIndex
CREATE UNIQUE INDEX "product_variant_barcode_key" ON "product_variant"("barcode");

-- CreateIndex
CREATE INDEX "product_variant_productId_idx" ON "product_variant"("productId");

-- CreateIndex
CREATE INDEX "product_variant_isActive_idx" ON "product_variant"("isActive");

-- CreateIndex
CREATE INDEX "product_variant_isDefault_idx" ON "product_variant"("isDefault");

-- CreateIndex
CREATE INDEX "product_highlight_productId_idx" ON "product_highlight"("productId");

-- CreateIndex
CREATE INDEX "product_highlight_sortOrder_idx" ON "product_highlight"("sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "product_attribute_slug_key" ON "product_attribute"("slug");

-- CreateIndex
CREATE INDEX "product_attribute_filterable_idx" ON "product_attribute"("filterable");

-- CreateIndex
CREATE INDEX "product_attribute_sortOrder_idx" ON "product_attribute"("sortOrder");

-- CreateIndex
CREATE INDEX "product_attribute_archivedAt_idx" ON "product_attribute"("archivedAt");

-- CreateIndex
CREATE INDEX "product_attribute_value_attributeId_idx" ON "product_attribute_value"("attributeId");

-- CreateIndex
CREATE INDEX "product_attribute_value_sortOrder_idx" ON "product_attribute_value"("sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "product_attribute_value_attributeId_value_key" ON "product_attribute_value"("attributeId", "value");

-- CreateIndex
CREATE INDEX "product_variant_attribute_value_attributeValueId_idx" ON "product_variant_attribute_value"("attributeValueId");

-- CreateIndex
CREATE INDEX "category_attribute_categoryId_idx" ON "category_attribute"("categoryId");

-- CreateIndex
CREATE INDEX "category_attribute_attributeId_idx" ON "category_attribute"("attributeId");

-- CreateIndex
CREATE INDEX "category_attribute_scope_idx" ON "category_attribute"("scope");

-- CreateIndex
CREATE INDEX "category_attribute_filterable_idx" ON "category_attribute"("filterable");

-- CreateIndex
CREATE INDEX "category_attribute_variantDefining_idx" ON "category_attribute"("variantDefining");

-- CreateIndex
CREATE INDEX "category_attribute_sortOrder_idx" ON "category_attribute"("sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "category_attribute_categoryId_attributeId_scope_key" ON "category_attribute"("categoryId", "attributeId", "scope");

-- CreateIndex
CREATE INDEX "product_attribute_assignment_productId_idx" ON "product_attribute_assignment"("productId");

-- CreateIndex
CREATE INDEX "product_attribute_assignment_attributeId_idx" ON "product_attribute_assignment"("attributeId");

-- CreateIndex
CREATE INDEX "product_attribute_assignment_attributeValueId_idx" ON "product_attribute_assignment"("attributeValueId");

-- CreateIndex
CREATE UNIQUE INDEX "product_attribute_assignment_productId_attributeId_key" ON "product_attribute_assignment"("productId", "attributeId");

-- CreateIndex
CREATE INDEX "product_attribute_assignment_value_attributeValueId_idx" ON "product_attribute_assignment_value"("attributeValueId");

-- CreateIndex
CREATE UNIQUE INDEX "ecommerce_customer_normalizedEmail_key" ON "ecommerce_customer"("normalizedEmail");

-- CreateIndex
CREATE UNIQUE INDEX "ecommerce_customer_userId_key" ON "ecommerce_customer"("userId");

-- CreateIndex
CREATE INDEX "ecommerce_customer_name_idx" ON "ecommerce_customer"("name");

-- CreateIndex
CREATE INDEX "ecommerce_customer_phone_idx" ON "ecommerce_customer"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "discount_code_code_key" ON "discount_code"("code");

-- CreateIndex
CREATE INDEX "discount_code_isActive_idx" ON "discount_code"("isActive");

-- CreateIndex
CREATE INDEX "discount_code_startsAt_endsAt_idx" ON "discount_code"("startsAt", "endsAt");

-- CreateIndex
CREATE UNIQUE INDEX "discount_redemption_orderId_key" ON "discount_redemption"("orderId");

-- CreateIndex
CREATE INDEX "discount_redemption_discountCodeId_createdAt_idx" ON "discount_redemption"("discountCodeId", "createdAt");

-- CreateIndex
CREATE INDEX "discount_redemption_discountCodeId_customerKey_idx" ON "discount_redemption"("discountCodeId", "customerKey");

-- CreateIndex
CREATE INDEX "supplier_isActive_idx" ON "supplier"("isActive");

-- CreateIndex
CREATE INDEX "supplier_email_idx" ON "supplier"("email");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_location_code_key" ON "inventory_location"("code");

-- CreateIndex
CREATE INDEX "inventory_location_isActive_idx" ON "inventory_location"("isActive");

-- CreateIndex
CREATE INDEX "inventory_batch_variantId_idx" ON "inventory_batch"("variantId");

-- CreateIndex
CREATE INDEX "inventory_batch_supplierId_idx" ON "inventory_batch"("supplierId");

-- CreateIndex
CREATE INDEX "inventory_batch_expiryDate_idx" ON "inventory_batch"("expiryDate");

-- CreateIndex
CREATE INDEX "inventory_batch_attribute_assignment_batchId_idx" ON "inventory_batch_attribute_assignment"("batchId");

-- CreateIndex
CREATE INDEX "inventory_batch_attribute_assignment_attributeId_idx" ON "inventory_batch_attribute_assignment"("attributeId");

-- CreateIndex
CREATE INDEX "inventory_batch_attribute_assignment_attributeValueId_idx" ON "inventory_batch_attribute_assignment"("attributeValueId");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_batch_attribute_assignment_batchId_attributeId_key" ON "inventory_batch_attribute_assignment"("batchId", "attributeId");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_stock_stockKey_key" ON "inventory_stock"("stockKey");

-- CreateIndex
CREATE INDEX "inventory_stock_variantId_idx" ON "inventory_stock"("variantId");

-- CreateIndex
CREATE INDEX "inventory_stock_locationId_idx" ON "inventory_stock"("locationId");

-- CreateIndex
CREATE INDEX "inventory_stock_batchId_idx" ON "inventory_stock"("batchId");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_stock_variantId_locationId_batchId_key" ON "inventory_stock"("variantId", "locationId", "batchId");

-- CreateIndex
CREATE INDEX "inventory_movement_variantId_createdAt_idx" ON "inventory_movement"("variantId", "createdAt");

-- CreateIndex
CREATE INDEX "inventory_movement_locationId_createdAt_idx" ON "inventory_movement"("locationId", "createdAt");

-- CreateIndex
CREATE INDEX "inventory_movement_batchId_idx" ON "inventory_movement"("batchId");

-- CreateIndex
CREATE INDEX "inventory_movement_type_createdAt_idx" ON "inventory_movement"("type", "createdAt");

-- CreateIndex
CREATE INDEX "inventory_movement_referenceType_referenceId_idx" ON "inventory_movement"("referenceType", "referenceId");

-- CreateIndex
CREATE INDEX "inventory_movement_actorUserId_idx" ON "inventory_movement"("actorUserId");

-- CreateIndex
CREATE INDEX "stock_reservation_variantId_idx" ON "stock_reservation"("variantId");

-- CreateIndex
CREATE INDEX "stock_reservation_locationId_idx" ON "stock_reservation"("locationId");

-- CreateIndex
CREATE INDEX "stock_reservation_batchId_idx" ON "stock_reservation"("batchId");

-- CreateIndex
CREATE INDEX "stock_reservation_status_expiresAt_idx" ON "stock_reservation"("status", "expiresAt");

-- CreateIndex
CREATE INDEX "stock_reservation_referenceType_referenceId_idx" ON "stock_reservation"("referenceType", "referenceId");

-- CreateIndex
CREATE UNIQUE INDEX "order_orderNumber_key" ON "order"("orderNumber");

-- CreateIndex
CREATE UNIQUE INDEX "order_checkoutKey_key" ON "order"("checkoutKey");

-- CreateIndex
CREATE INDEX "order_userId_idx" ON "order"("userId");

-- CreateIndex
CREATE INDEX "order_customerEmail_idx" ON "order"("customerEmail");

-- CreateIndex
CREATE INDEX "order_ecommerceCustomerId_idx" ON "order"("ecommerceCustomerId");

-- CreateIndex
CREATE INDEX "order_orderStatus_idx" ON "order"("orderStatus");

-- CreateIndex
CREATE INDEX "order_paymentStatus_idx" ON "order"("paymentStatus");

-- CreateIndex
CREATE INDEX "order_deliveryStatus_idx" ON "order"("deliveryStatus");

-- CreateIndex
CREATE INDEX "order_inventoryStatus_idx" ON "order"("inventoryStatus");

-- CreateIndex
CREATE INDEX "order_paymentMethod_idx" ON "order"("paymentMethod");

-- CreateIndex
CREATE INDEX "order_discountCodeId_idx" ON "order"("discountCodeId");

-- CreateIndex
CREATE INDEX "order_shippingRateId_idx" ON "order"("shippingRateId");

-- CreateIndex
CREATE INDEX "order_placedAt_idx" ON "order"("placedAt");

-- CreateIndex
CREATE INDEX "order_refund_orderId_createdAt_idx" ON "order_refund"("orderId", "createdAt");

-- CreateIndex
CREATE INDEX "order_refund_actorUserId_idx" ON "order_refund"("actorUserId");

-- CreateIndex
CREATE INDEX "order_address_type_idx" ON "order_address"("type");

-- CreateIndex
CREATE UNIQUE INDEX "order_address_orderId_type_key" ON "order_address"("orderId", "type");

-- CreateIndex
CREATE INDEX "order_line_item_orderId_idx" ON "order_line_item"("orderId");

-- CreateIndex
CREATE INDEX "order_line_item_productId_idx" ON "order_line_item"("productId");

-- CreateIndex
CREATE INDEX "order_line_item_variantId_idx" ON "order_line_item"("variantId");

-- CreateIndex
CREATE INDEX "order_status_event_orderId_createdAt_idx" ON "order_status_event"("orderId", "createdAt");

-- CreateIndex
CREATE INDEX "order_status_event_type_createdAt_idx" ON "order_status_event"("type", "createdAt");

-- CreateIndex
CREATE INDEX "order_status_event_actorUserId_idx" ON "order_status_event"("actorUserId");

-- CreateIndex
CREATE UNIQUE INDEX "order_payment_idempotencyKey_key" ON "order_payment"("idempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "order_payment_reversesId_key" ON "order_payment"("reversesId");

-- CreateIndex
CREATE INDEX "order_payment_orderId_createdAt_idx" ON "order_payment"("orderId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "order_recovery_orderId_key" ON "order_recovery"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "shipping_rate_code_key" ON "shipping_rate"("code");

-- CreateIndex
CREATE INDEX "shipping_rate_isActive_idx" ON "shipping_rate"("isActive");

-- CreateIndex
CREATE INDEX "shipping_rate_isDefault_idx" ON "shipping_rate"("isDefault");

-- CreateIndex
CREATE INDEX "shipping_rate_currency_idx" ON "shipping_rate"("currency");

-- CreateIndex
CREATE INDEX "shipping_rate_sortOrder_idx" ON "shipping_rate"("sortOrder");

-- CreateIndex
CREATE INDEX "shipping_rate_archivedAt_sortOrder_idx" ON "shipping_rate"("archivedAt", "sortOrder");

-- CreateIndex
CREATE INDEX "feedback_userId_idx" ON "feedback"("userId");

-- CreateIndex
CREATE INDEX "feedback_createdAt_idx" ON "feedback"("createdAt");

-- CreateIndex
CREATE INDEX "feedback_status_idx" ON "feedback"("status");

-- CreateIndex
CREATE INDEX "notification_userId_idx" ON "notification"("userId");

-- CreateIndex
CREATE INDEX "notification_userId_createdAt_idx" ON "notification"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "rbac_permission_name_key" ON "rbac_permission"("name");

-- CreateIndex
CREATE UNIQUE INDEX "rbac_role_slug_key" ON "rbac_role"("slug");

-- CreateIndex
CREATE INDEX "rbac_user_role_roleId_idx" ON "rbac_user_role"("roleId");

-- CreateIndex
CREATE UNIQUE INDEX "visitor_identity_visitorId_key" ON "visitor_identity"("visitorId");

-- CreateIndex
CREATE INDEX "visitor_identity_firstSeenAt_idx" ON "visitor_identity"("firstSeenAt");

-- CreateIndex
CREATE INDEX "visitor_identity_lastSeenAt_idx" ON "visitor_identity"("lastSeenAt");

-- CreateIndex
CREATE INDEX "visitor_session_visitorIdentityId_startedAt_idx" ON "visitor_session"("visitorIdentityId", "startedAt");

-- CreateIndex
CREATE INDEX "visitor_session_visitorIdentityId_isBot_lastSeenAt_idx" ON "visitor_session"("visitorIdentityId", "isBot", "lastSeenAt");

-- CreateIndex
CREATE INDEX "visitor_session_lastSeenAt_idx" ON "visitor_session"("lastSeenAt");

-- CreateIndex
CREATE INDEX "visitor_session_startedAt_idx" ON "visitor_session"("startedAt");

-- CreateIndex
CREATE INDEX "visitor_session_startedAt_userId_idx" ON "visitor_session"("startedAt", "userId");

-- CreateIndex
CREATE INDEX "visitor_session_isBot_startedAt_idx" ON "visitor_session"("isBot", "startedAt");

-- CreateIndex
CREATE INDEX "visitor_session_userId_startedAt_idx" ON "visitor_session"("userId", "startedAt");

-- CreateIndex
CREATE INDEX "webhook_event_status_createdAt_idx" ON "webhook_event"("status", "createdAt");

-- CreateIndex
CREATE INDEX "webhook_event_eventType_createdAt_idx" ON "webhook_event"("eventType", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "webhook_event_provider_eventId_key" ON "webhook_event"("provider", "eventId");

-- AddForeignKey
ALTER TABLE "activity_event" ADD CONSTRAINT "activity_event_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "activity_event" ADD CONSTRAINT "activity_event_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "rbac_role"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_inviterId_fkey" FOREIGN KEY ("inviterId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "session" ADD CONSTRAINT "session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_auth_method" ADD CONSTRAINT "user_auth_method_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account" ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "twoFactor" ADD CONSTRAINT "twoFactor_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category" ADD CONSTRAINT "category_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "product_brand"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_variant" ADD CONSTRAINT "product_variant_productId_fkey" FOREIGN KEY ("productId") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_highlight" ADD CONSTRAINT "product_highlight_productId_fkey" FOREIGN KEY ("productId") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_value" ADD CONSTRAINT "product_attribute_value_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES "product_attribute"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_variant_attribute_value" ADD CONSTRAINT "product_variant_attribute_value_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_variant_attribute_value" ADD CONSTRAINT "product_variant_attribute_value_attributeValueId_fkey" FOREIGN KEY ("attributeValueId") REFERENCES "product_attribute_value"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_attribute" ADD CONSTRAINT "category_attribute_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "category"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_attribute" ADD CONSTRAINT "category_attribute_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES "product_attribute"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_assignment" ADD CONSTRAINT "product_attribute_assignment_productId_fkey" FOREIGN KEY ("productId") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_assignment" ADD CONSTRAINT "product_attribute_assignment_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES "product_attribute"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_assignment" ADD CONSTRAINT "product_attribute_assignment_attributeValueId_fkey" FOREIGN KEY ("attributeValueId") REFERENCES "product_attribute_value"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_assignment_value" ADD CONSTRAINT "product_attribute_assignment_value_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "product_attribute_assignment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attribute_assignment_value" ADD CONSTRAINT "product_attribute_assignment_value_attributeValueId_fkey" FOREIGN KEY ("attributeValueId") REFERENCES "product_attribute_value"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ecommerce_customer" ADD CONSTRAINT "ecommerce_customer_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "discount_redemption" ADD CONSTRAINT "discount_redemption_discountCodeId_fkey" FOREIGN KEY ("discountCodeId") REFERENCES "discount_code"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "discount_redemption" ADD CONSTRAINT "discount_redemption_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_batch" ADD CONSTRAINT "inventory_batch_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_batch" ADD CONSTRAINT "inventory_batch_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "supplier"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_batch_attribute_assignment" ADD CONSTRAINT "inventory_batch_attribute_assignment_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "inventory_batch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_batch_attribute_assignment" ADD CONSTRAINT "inventory_batch_attribute_assignment_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES "product_attribute"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_batch_attribute_assignment" ADD CONSTRAINT "inventory_batch_attribute_assignment_attributeValueId_fkey" FOREIGN KEY ("attributeValueId") REFERENCES "product_attribute_value"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_stock" ADD CONSTRAINT "inventory_stock_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_stock" ADD CONSTRAINT "inventory_stock_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "inventory_location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_stock" ADD CONSTRAINT "inventory_stock_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "inventory_batch"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "inventory_location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "inventory_batch"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_reservation" ADD CONSTRAINT "stock_reservation_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_reservation" ADD CONSTRAINT "stock_reservation_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "inventory_location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_reservation" ADD CONSTRAINT "stock_reservation_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "inventory_batch"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order" ADD CONSTRAINT "order_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order" ADD CONSTRAINT "order_ecommerceCustomerId_fkey" FOREIGN KEY ("ecommerceCustomerId") REFERENCES "ecommerce_customer"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order" ADD CONSTRAINT "order_discountCodeId_fkey" FOREIGN KEY ("discountCodeId") REFERENCES "discount_code"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order" ADD CONSTRAINT "order_shippingRateId_fkey" FOREIGN KEY ("shippingRateId") REFERENCES "shipping_rate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_refund" ADD CONSTRAINT "order_refund_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_refund" ADD CONSTRAINT "order_refund_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_address" ADD CONSTRAINT "order_address_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_line_item" ADD CONSTRAINT "order_line_item_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_line_item" ADD CONSTRAINT "order_line_item_productId_fkey" FOREIGN KEY ("productId") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_line_item" ADD CONSTRAINT "order_line_item_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "product_variant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_status_event" ADD CONSTRAINT "order_status_event_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_status_event" ADD CONSTRAINT "order_status_event_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_payment" ADD CONSTRAINT "order_payment_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_payment" ADD CONSTRAINT "order_payment_reversesId_fkey" FOREIGN KEY ("reversesId") REFERENCES "order_payment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_recovery" ADD CONSTRAINT "order_recovery_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "feedback" ADD CONSTRAINT "feedback_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification" ADD CONSTRAINT "notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_role_permission" ADD CONSTRAINT "rbac_role_permission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "rbac_role"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_role_permission" ADD CONSTRAINT "rbac_role_permission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "rbac_permission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_user_role" ADD CONSTRAINT "rbac_user_role_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_user_role" ADD CONSTRAINT "rbac_user_role_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "rbac_role"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_user_permission_override" ADD CONSTRAINT "rbac_user_permission_override_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rbac_user_permission_override" ADD CONSTRAINT "rbac_user_permission_override_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "rbac_permission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitor_session" ADD CONSTRAINT "visitor_session_visitorIdentityId_fkey" FOREIGN KEY ("visitorIdentityId") REFERENCES "visitor_identity"("id") ON DELETE CASCADE ON UPDATE CASCADE;
